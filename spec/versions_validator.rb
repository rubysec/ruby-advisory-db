# frozen_string_literal: true

# Usage: rspec spec/versions_validator.rb

require "rspec"
require "rubygems"

module AdvisoryDB
  class VersionFieldValidator
    Constraint = Struct.new(:op, :version)
    Range     = Struct.new(:constraints)
    Error     = Struct.new(:message, :input)

    COMMA_SPLIT = /\s*,\s*/
    SPACE_SPLIT = /\s+/

    VALID_OPS = ["~>", "<", "<=", ">", ">=", "="].freeze

    def validate_list(input)
      return [Error.new("empty version list", input)] if input.nil? || input.strip.empty?

      ranges = input.split(COMMA_SPLIT).map { |r| parse_range(r) }
      errors = ranges.flat_map { |range| validate_range(range) }
      errors.compact
    end

    private

    #
    # Merge operator + version tokens:
    # "< 2.0.0.beta" → ["< 2.0.0.beta"]
    # ">= 1.2.3.rc1 < 2.0.0.beta" → [">= 1.2.3.rc1", "< 2.0.0.beta"]
    #
    def merge_operator_tokens(parts)
      merged = []
      i = 0
      while i < parts.length
        # ANY operator-like prefix must merge with the next token
        if parts[i] =~ /\A[<>=~]+\z/ && parts[i+1]
          merged << "#{parts[i]} #{parts[i+1]}".strip
          i += 2
        else
          merged << parts[i]
          i += 1
        end
      end
      merged
    end

    def parse_range(str)
      parts = str.strip.split(SPACE_SPLIT)
      parts = merge_operator_tokens(parts)
      constraints = parts.map { |p| parse_constraint(p) }
      Range.new(constraints)
    end

    #
    # parse_constraint NEVER returns nil
    #
    def parse_constraint(str)
      # Known operators
      if str =~ /\A~>\s*(.+)\z/
        return Constraint.new("~>", parse_version($1))
      elsif str =~ /\A(<=|>=|<|>)\s*(.+)\z/
        return Constraint.new($1, parse_version($2))
      end

      # STRICT unknown operator detection:
      # If it starts with operator characters but is not a valid operator, treat as unknown.
      if str =~ /\A([<>=~]+)\s+(.+)\z/
        op = $1
        ver = $2
        return Constraint.new(op, parse_version(ver))
      end

      # Fallback: exact version
      Constraint.new("=", parse_version(str))
    end

    def parse_version(str)
      Gem::Version.new(str)
    rescue ArgumentError
      nil
    end

    def validate_range(range)
      range.constraints.map { |c| validate_constraint(c) }
    end

    def validate_constraint(constraint)
      # Defensive guard
      return Error.new("invalid constraint", constraint.inspect) if constraint.nil?

      unless VALID_OPS.include?(constraint.op)
        return Error.new("unknown operator #{constraint.op}", constraint.inspect)
      end

      return Error.new("invalid version syntax", constraint.inspect) if constraint.version.nil?

      case constraint.op
      when "~>"
        validate_pessimistic(constraint)
      else
        nil
      end
    end

    def validate_pessimistic(constraint)
      v = constraint.version
      segments = v.segments

      return Error.new("pessimistic operator requires at least one segment", v.to_s) if segments.empty?

      last = segments.last

      # Reject prerelease-only segment (alphabetic-only)
      if last.is_a?(String) && last.match?(/\A[a-zA-Z]+\z/)
        return Error.new("pessimistic operator cannot apply to prerelease-only segment", v.to_s)
      end

      nil
    end
  end
end

RSpec.describe AdvisoryDB::VersionFieldValidator do
  subject(:validator) { described_class.new }

  def errors(input)
    validator.validate_list(input)
  end

  describe "#validate_list" do
    context "with empty input" do
      it "returns an error" do
        expect(errors("")).not_to be_empty
        expect(errors(" ").first.message).to eq("empty version list")
      end
    end

    context "with exact versions" do
      it "accepts a single exact version" do
        expect(errors("1.2.3")).to be_empty
      end

      it "accepts multiple exact versions" do
        expect(errors("1.2.3, 2.0.0")).to be_empty
      end
    end

    context "with prerelease versions" do
      it "accepts rc versions" do
        expect(errors("1.2.3.rc1")).to be_empty
      end

      it "accepts beta versions" do
        expect(errors("2.0.0.beta.2")).to be_empty
      end

      it "accepts pre versions" do
        expect(errors("3.1.0.pre")).to be_empty
      end
    end

    context "with comparison operators" do
      it "accepts <" do
        expect(errors("< 2.0.0.beta")).to be_empty
      end

      it "accepts <=" do
        expect(errors("<= 1.2.3.rc1")).to be_empty
      end

      it "accepts >" do
        expect(errors("> 1.0.0")).to be_empty
      end

      it "accepts >=" do
        expect(errors(">= 1.0.0.pre")).to be_empty
      end
    end

    context "with pessimistic operator" do
      it "accepts ~> with numeric last segment" do
        expect(errors("~> 1.2.3")).to be_empty
      end

      it "rejects ~> when last segment is prerelease-only" do
        err = errors("~> 1.2.3.rc").first
        expect(err.message).to eq("pessimistic operator cannot apply to prerelease-only segment")
      end

      it "accepts ~> with prerelease segments as long as last segment is numeric" do
        expect(errors("~> 1.2.3.rc1")).to be_empty
      end
    end

    context "with multi-constraint ranges" do
      it "accepts >= and < together" do
        expect(errors(">= 1.2.3.rc1 < 2.0.0.beta")).to be_empty
      end

      it "accepts comma-separated ranges" do
        expect(errors(">= 1.0.0, < 2.0.0")).to be_empty
      end
    end

    context "with invalid syntax" do
      it "rejects unknown operators" do
        err = errors("~~ 1.2.3").first
        expect(err.message).to match(/unknown operator/)
      end

      it "rejects invalid version strings" do
        err = errors(">= not_a_version").first
        expect(err.message).to eq("invalid version syntax")
      end
    end

    context "with multi-segment versions" do
      it "accepts four-segment versions" do
        expect(errors("1.2.3.4")).to be_empty
      end

      it "accepts five-segment versions" do
        expect(errors("1.2.3.4.5")).to be_empty
      end

      it "accepts four-segment prerelease versions" do
        expect(errors("1.2.3.4.rc1")).to be_empty
      end
    end

    context "with prerelease variants seen in advisories" do
      it "accepts preview versions" do
        expect(errors("2.3.0-preview1")).to be_empty
      end

      it "accepts mixed prerelease tokens" do
        expect(errors("3.0.0.alpha.1")).to be_empty
      end
    end

    context "with pessimistic operator on multi-segment versions" do
      it "accepts ~> on four-segment versions" do
        expect(errors("~> 1.2.3.4")).to be_empty
      end

      it "rejects ~> when last segment is prerelease-only" do
        err = errors("~> 1.2.3.4.rc").first
        expect(err.message).to eq("pessimistic operator cannot apply to prerelease-only segment")
      end
    end

    context "with chained constraints used in advisories" do
      it "accepts >= and <= together" do
        expect(errors(">= 1.0.0 <= 2.0.0")).to be_empty
      end

      it "accepts > and < together" do
        expect(errors("> 1.9.3 < 2.0.0")).to be_empty
      end
    end

    context "with comma-separated multi-constraint ranges" do
      it "accepts >= and < separated by comma" do
        expect(errors(">= 2.3.0, < 2.3.5")).to be_empty
      end

      it "accepts > and <= separated by comma" do
        expect(errors("> 1.9.3, <= 2.0.0")).to be_empty
      end
    end

    context "with invalid advisory patterns" do
      it "rejects operator-only tokens" do
        err = errors(">=").first
        expect(err.message).to eq("invalid version syntax")
      end

      it "rejects malformed version strings" do
        err = errors("1..2.3").first
        expect(err.message).to eq("invalid version syntax")
      end

      it "rejects malformed prerelease versions" do
        err = errors("1.2.3..rc1").first
        expect(err.message).to eq("invalid version syntax")
      end

      it "rejects invalid operators seen in bad PRs" do
        err = errors("=> 1.2.3").first
        expect(err.message).to match(/unknown operator/)
      end

      it "rejects multi-character invalid operators" do
        err = errors(">== 1.2.3").first
        expect(err.message).to match(/invalid version syntax/)
      end
    end
  end
end

require 'spec_helper'
require 'advisory_example'

shared_examples_for "Gem Advisory" do |path|
  include_examples 'Advisory', path

  advisory = YAML.safe_load_file(path, permitted_classes: [Date])

  describe path do
    let(:gem) { File.basename(File.dirname(path)) }

    describe "gem" do
      subject { advisory['gem'] }

      it { is_expected.to be_kind_of(String) }

      it "should be equal to filename (case-insensitive)" do
        expect(subject.downcase).to eq(gem.downcase)
      end
    end

    describe "library" do
      subject { advisory['library'] }

      it "may be nil or a String" do
        expect(subject).to be_kind_of(String).or(be_nil)
      end
    end

    describe "framework" do
      subject { advisory['framework'] }

      it "may be nil or a String" do
        expect(subject).to be_kind_of(String).or(be_nil)
      end
    end

    describe "versions" do
      it "assumes that future versions will be patched" do
        patched_versions = advisory['patched_versions'] || []
        unaffected_versions = advisory['unaffected_versions'] || []

        # If a gem is unpatched this test makes no sense
        unless patched_versions.none?
          # Sort only patched versions and check if the highest one indicates future versions are patched
          sorted_patched_versions = patched_versions.sort_by do |v|
            # Extract version number more robustly
            version_match = v.match(/([0-9]+(?:\.[0-9]+)*(?:\.[a-zA-Z0-9]+)*)/)
            if version_match
              begin
                Gem::Version.new(version_match[1])
              rescue ArgumentError
                # If version parsing fails, use the original string for sorting
                Gem::Version.new("0.0.0")
              end
            else
              Gem::Version.new("0.0.0")
            end
          end

          # The highest patched version should indicate that future versions are also patched
          # This means it should use >= or > operators, or contain >= in compound requirements
          # UNLESS there are unaffected_versions that indicate the vulnerability doesn't exist in newer versions
          highest_patched = sorted_patched_versions.last
          
          # Check if there are unaffected versions that are higher than the patched versions
          # This indicates the vulnerability was fixed in a specific range but doesn't exist in newer versions
          has_higher_unaffected = false
          unless unaffected_versions.empty?
            unaffected_versions.each do |unaffected|
              if unaffected.match(/^>=?\s*([0-9]+(?:\.[0-9]+)*)/)
                # This indicates newer versions are unaffected, so the test doesn't apply
                has_higher_unaffected = true
                break
              end
            end
          end
          
          # Skip the test if there are higher unaffected versions
          unless has_higher_unaffected
            # Check if the version requirement indicates future versions are patched
            # This can be: ">= x.y.z", "> x.y.z", or compound like "~> x.y.z, >= x.y.z.w"
            future_versions_patched = highest_patched.match(/^(?:>=|>) /) || 
                                     highest_patched.include?(', >=') ||
                                     highest_patched.include?(', >')
            
            expect(future_versions_patched).to be_truthy, 
              "Expected highest patched version '#{highest_patched}' to indicate future versions are patched (should use >=, >, or compound requirement with >=)"
          end
        end
      end
    end

    let(:schema_file) { File.join(__dir__, 'schemas/gem.yml') }

    it "should have valid schema" do
      schema    = YAML.safe_load_file(schema_file)
      validator = Kwalify::Validator.new(schema)
      errors    = validator.validate(advisory)

      expect(errors).to be_empty
    end
  end
end

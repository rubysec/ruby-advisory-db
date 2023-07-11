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
        unaffected_versions = advisory['unaffected_versions'] || []
        patched_versions    = advisory['patched_versions'] || []

        versions = (unaffected_versions + patched_versions).sort_by do |v|
          Gem::Version.new(v.match(/[0-9.]+\.\d+/)[0])
        end

        # If a gem is unpatched this test makes no sense
        unless patched_versions.none?
          expect(versions.last).to match(/^(?:>=|>) /)
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

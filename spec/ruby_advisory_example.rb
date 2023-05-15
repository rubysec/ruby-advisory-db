require 'spec_helper'
require 'advisory_example'

shared_examples_for "Rubies Advisory" do |path|
  include_examples 'Advisory', path

  advisory = YAML.safe_load_file(path, permitted_classes: [Date])

  describe path do
    let(:engine) { File.basename(File.dirname(path)) }

    describe "engine" do
      subject { advisory['engine'] }

      it { is_expected.to be_kind_of(String) }

      it "should be equal to filename (case-insensitive)" do
        expect(subject.downcase).to eq(engine.downcase)
      end
    end

    let(:schema_file) { File.join(__dir__, 'schemas/ruby.yml') }

    it "should have valid schema" do
      schema    = YAML.safe_load_file(schema_file)
      validator = Kwalify::Validator.new(schema)
      errors    = validator.validate(advisory)

      expect(errors).to be_empty
    end
  end
end

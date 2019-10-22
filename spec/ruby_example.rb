load File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'advisory_example'

shared_examples_for "Rubies Advisory" do |path|
  include_examples 'Advisory', path

  advisory = YAML.load_file(path)

  describe path do
    let(:engine) { File.basename(File.dirname(path)) }

    describe "engine" do
      subject { advisory['engine'] }

      it { is_expected.to be_kind_of(String) }
      it "should be equal to filename (case-insensitive)" do
        expect(subject.downcase).to eq(engine.downcase)
      end
    end

    it "should have valid schema" do
      schema = YAML.load_file(File.join(File.dirname(__FILE__), 'schemas/ruby.yml'))
      validator = Kwalify::Validator.new(schema)
      errors = validator.validate(advisory)
      expect(errors).to be_empty
    end
  end
end


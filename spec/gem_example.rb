load File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'advisory_example'

shared_examples_for "Gem Advisory" do |path|
  include_examples 'Advisory', path

  advisory = YAML.load_file(path)

  describe path do
    let(:gem) { File.basename(File.dirname(path)) }

    describe "gem" do
      subject { advisory['gem'] }

      it { is_expected.to be_kind_of(String) }
      it "should be equal to filename (case-insensitive)" do
        expect(subject.downcase).to eq(gem.downcase)
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
          expect(versions.last.match(/^>=|^>/)).to be_truthy
        end
      end
    end
  end
end

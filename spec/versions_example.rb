require 'rspec'

RSpec.shared_examples_for "Versions" do |versions|
  versions.each do |version|
    describe(version) do
      subject { version.split(', ') }

      it "must contain between 1-2 version ranges" do
        expect(subject.length).to be_between(1,2)
      end

      it "each version must start with a valid operator" do
        expect(subject).to all(match(/^(?:<=|<|>=|>|~>|=) /))
      end

      it "should contain valid RubyGem version requirements" do
        expect {
          Gem::Requirement.new(*subject)
        }.not_to raise_error
      end
    end
  end
end

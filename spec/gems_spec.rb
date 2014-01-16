load File.join(File.dirname(__FILE__), 'spec_helper.rb')
load File.join(File.dirname(__FILE__), 'advisory_example.rb')
describe "gems" do
  Dir.glob(File.join(File.dirname(__FILE__), '../gems/*/*.yml')) do |path|
    include_examples 'Advisory', path
  end
end

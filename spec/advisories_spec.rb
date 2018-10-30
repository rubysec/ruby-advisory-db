load File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'gem_example'
require 'library_example'
require 'ruby_example'

describe "gems" do
  Dir.glob(File.join(File.dirname(__FILE__), '../gems/*/*.yml')) do |path|
    include_examples 'Gem Advisory', path
  end

  it "shouldn't contain .yaml files" do
    yaml_files = Dir.glob(File.join(File.dirname(__FILE__), '../gems/*/*.yaml'))
    expect(yaml_files).to be_empty
  end
end

describe "libraries" do
  Dir.glob(File.join(File.dirname(__FILE__), '../libraries/*/*.yml')) do |path|
    include_examples 'Libraries Advisory', path
  end

  it "shouldn't contain .yaml files" do
    yaml_files = Dir.glob(File.join(File.dirname(__FILE__), '../libraries/*/*.yaml'))
    expect(yaml_files).to be_empty
  end
end

describe "rubies" do
  Dir.glob(File.join(File.dirname(__FILE__), '../rubies/*/*.yml')) do |path|
    include_examples 'Rubies Advisory', path
  end

  it "shouldn't contain .yaml files" do
    yaml_files = Dir.glob(File.join(File.dirname(__FILE__), '../rubies/*/*.yaml'))
    expect(yaml_files).to be_empty
  end
end

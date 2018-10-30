load File.join(File.dirname(__FILE__), 'spec_helper.rb')
require 'gem_example'
require 'library_example'
require 'ruby_example'

describe "gems" do
  Dir.glob(File.join(File.dirname(__FILE__), '../gems/*/*')) do |path|
    include_examples 'Gem Advisory', path
  end
end

describe "libraries" do
  Dir.glob(File.join(File.dirname(__FILE__), '../libraries/*/*')) do |path|
    include_examples 'Libraries Advisory', path
  end
end

describe "rubies" do
  Dir.glob(File.join(File.dirname(__FILE__), '../rubies/*/*')) do |path|
    include_examples 'Rubies Advisory', path
  end
end


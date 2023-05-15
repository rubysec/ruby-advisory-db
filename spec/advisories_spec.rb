require 'spec_helper'
require 'gem_advisory_example'
require 'ruby_advisory_example'

describe "gems" do
  Dir.glob(File.join(ROOT,'gems/*/*')) do |path|
    include_examples 'Gem Advisory', path
  end
end

describe "rubies" do
  Dir.glob(File.join(ROOT, 'rubies/*/*')) do |path|
    include_examples 'Rubies Advisory', path
  end
end

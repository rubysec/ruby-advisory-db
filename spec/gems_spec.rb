require 'spec_helper'
require 'advisory_example'

describe "gems" do
  Dir.glob('gems/*/*.yml') do |path|
    include_examples 'Advisory', path
  end
end

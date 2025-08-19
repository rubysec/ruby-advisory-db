require 'spec_helper'
require 'gem_advisory_example'
require 'ruby_advisory_example'
require 'advisory_dir_example'

describe "gems" do
  Dir.glob(File.join(ROOT,'gems/*/*')) do |path|
    include_examples 'Gem Advisory', path
  end

  Dir.glob(File.join(File.dirname(__FILE__), '../gems/*')) do |dir|
    include_examples 'Advisory Directory', dir
  end

  let(:dir)           { File.join(ROOT,'gems') }
  let(:advisory_dirs) { Dir.glob('*', base: dir) }

  it "must not have any case-insensitive conflicting directory names" do
    case_sensitive_dirs = advisory_dirs.grep(/[A-Z]/)

    case_insensitive_mapping = case_sensitive_dirs.to_h { |dir|
                                 [dir, dir.downcase]
                               }

    conflicting_dirs = case_insensitive_mapping.select { |dir,lowercase_dir|
                         advisory_dirs.include?(lowercase_dir)
                       }

    expect(conflicting_dirs).to be_empty, -> {
      "#{conflicting_dirs.keys.join(', ')} conflicts with #{conflicting_dirs.values.join(', ')}"
    }
  end
end

describe "rubies" do
  Dir.glob(File.join(ROOT, 'rubies/*/*')) do |path|
    include_examples 'Rubies Advisory', path
  end

  Dir.glob(File.join(File.dirname(__FILE__), '../rubies/*')) do |dir|
    include_examples 'Advisory Directory', dir
  end
end

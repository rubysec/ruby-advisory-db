require 'yaml'

namespace :lint do
  begin
    require 'rspec/core/rake_task'

    RSpec::Core::RakeTask.new(:yaml)
  rescue LoadError => e
    task :spec do
      abort "Please run `gem install rspec` to install RSpec."
    end
  end
end

desc "Sync GitHub RubyGem Advisories into this project"
task :sync_github_advisories, [:gem_name] do |_, args|
  require_relative "lib/github_advisory_sync"
  t.exclude_pattern = "spec/schema_validation_spec.rb'
  GitHub::GitHubAdvisorySync.sync(gem_name: args[:gem_name])
end

RSpec::Core::RakeTask.new(:schema) do |t|
  t.pattern = 'spec/schema_validation_spec.rb'
end

task :lint    => ['lint:yaml']
task :default => [:schema, :lint]

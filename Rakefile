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
  GitHub::GitHubAdvisorySync.sync(gem_name: args[:gem_name])
end

task :lint    => ['lint:yaml']
task :default => :lint

require 'yaml'

begin
  require 'rspec/core/rake_task'
rescue LoadError
  warn "Warning: RSpec is not installed. Please run `gem install rspec` to install RSpec."
end

abort "yamllint is not installed. Install it with: pip install yamllint" \
  unless system("which yamllint > /dev/null 2>&1")

if defined?(RSpec::Core::RakeTask)
  namespace :lint do
    desc "Lint reports (excluding schema validation)"
    RSpec::Core::RakeTask.new(:yaml) do |t|
      t.exclude_pattern = 'spec/schema_validation_spec.rb'
    end

    desc "Validate report schema"
    RSpec::Core::RakeTask.new(:schema) do |t|
      t.pattern = 'spec/schema_validation_spec.rb'
    end
  end

  desc "Run all linting tasks"
  task :lint    => [ 'lint:schema', 'lint:yaml' ]

  desc "Run rad-ignores.sh to generate ignore patterns"
  task :ignores do
    sh "bash lib/rad-ignores.sh"
  end

  desc "Run yamllint command on all 'gems/*/*.yml' and 'rubies/*/*.yml' files"
  task :yamllint do
    sh "yamllint gems rubies"
  end

  task :default => [ :lint, :ignores, :yamllint ]
end

desc "Sync GitHub RubyGem Advisories into this project"
task :sync_github_advisories, [:gem_name] do |_, args|
  require_relative "lib/github_advisory_sync"
  GitHub::GitHubAdvisorySync.sync(gem_name: args[:gem_name])
end

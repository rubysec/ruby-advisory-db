require 'yaml'

begin
  gem 'rspec', '~> 2.4'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new
rescue LoadError => e
  task :spec do
    abort "Please run `gem install rspec` to install RSpec."
  end
end
task :test    => :spec
task :default => :spec

namespace :lint do
  task :cve do
    Dir.glob('gems/*/*.yml') do |path|
      advisory = YAML.load_file(path)

      unless advisory['cve']
        puts "Missing CVE: #{path}"
      end
    end
  end
end

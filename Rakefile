require 'yaml'
require 'nokogiri'
require 'open-uri'

namespace :lint do
  begin
    require 'rspec/core/rake_task'

    RSpec::Core::RakeTask.new(:yaml)
  rescue LoadError => e
    task :spec do
      abort "Please run `gem install rspec` to install RSpec."
    end
  end

  task :cve do
    Dir.glob('{gems,libraries,rubies}/*/*.yml') do |path|
      advisory = YAML.load_file(path)

      unless advisory['cve']
        puts "Missing CVE: #{path}"
      end
    end
  end
end

config = YAML.load(File.read("./config.yml"))
namespace :db do
  # TODO: sleep after each generation
  desc "generate files"
  task :update => config.select {|k,attrs| attrs["exec"]}.keys.map { |name| "db:update:#{name}"}

  namespace :update do
    config.each do |name, attrs|
      next unless attrs["exec"]
      desc "generate #{name} files"
      task name do
        doc = open(attrs["url"]) { |f| Nokogiri::XML(f) }
        doc.xpath(attrs["entry_condition"]).each do |elem|
          h = attrs["base_attributes"].merge(attrs["attribute_conditions"].map {|k, conds|
            if conds.kind_of?(Array)
              # FIXME
              [k, elem.xpath(conds[0]).first.xpath(conds[1]).to_s]
            else
              [k, elem.xpath(conds).first.content]
            end
          }.to_h)
          path = File.join(attrs["path"], "CVE-" + h["cve"] + ".yml")
          if !File.exists?(path)
            File.open(path, "w") do |f|
              f.write(h.to_yaml)
            end
          end
        end
      end
    end
  end
end

task :lint    => ['lint:yaml', 'lint:cve']
task :default => :lint

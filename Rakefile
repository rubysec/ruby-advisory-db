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

  task :cve do
    Dir.glob('{gems,libraries,rubies}/*/*.yml') do |path|
      advisory = YAML.load_file(path)

      unless advisory['cve']
        puts "Missing CVE: #{path}"
      end
    end
  end
end

task :lint    => ['lint:yaml', 'lint:cve']
task :default => :lint

def to_rubysec_id(year, num)
  "RUBYSEC-#{year}-#{sprintf '%04d', num}"
end

def from_rubysec_id(rubysec_id)
  year, id = rubysec_id.match(/RUBYSEC-(\d{4})-(\d{4})/).captures
  id.to_i
end

task :reserve_id, [:year] do |t, args|
  path = "rubysec_ids.yml"
  year = !args[:year].nil? ? args[:year].to_i : Time.now.year

  rubysec_ids = YAML.load_file(path)
  unless rubysec_ids[year]
    rubysec_ids[year] = []
  end
  last_entry = rubysec_ids[year].last
  if last_entry
    last_rubysec_id = last_entry.split(" - ").first
    new_id = from_rubysec_id(last_rubysec_id) + 1
  else
    new_id = 1
  end 

  if new_id > 9900
    warn "We're close to running out of ids for #{year}. Consider upgrading to a 5 digit naming scheme"
  elsif new_id > 9999
    throw "Ran out of ids for #{year}. We need to upgrade to a 5 digit naming scheme"
  end

  new_rubysec_id = to_rubysec_id(year, new_id)
  user_name = `git config user.name`.strip
  puts "Reserving #{new_rubysec_id} for #{user_name}"
  rubysec_ids[year] << "#{new_rubysec_id} - #{user_name}"
  rubysec_ids = rubysec_ids.sort.to_h
  File.open(path, 'w') do |f|
    f.write rubysec_ids.to_yaml
    
  end
end

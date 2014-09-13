require "yaml"
if ARGV.length != 1
  puts "usage: ruby get_stats.rb YEAR"
  exit -1
end
if ARGV[0] !~ /\d\d\d\d/
  puts "usage: ruby get_stats.rb YEAR"
  exit -2
end
year = Integer(ARGV[0])

result = {}
counter = 0

Dir.entries("gems").each do |gem|
  $stderr.puts "\nParsing gem #{gem}"
  $stderr.puts "|"
  issues = Dir.entries("gems/#{gem}")
  issues.each do |issue|
    next if File.directory?(issue)
    next if !issue.end_with?(".yml")
    $stderr.puts "-- Parsing #{issue}"
    data = YAML::load(File.read("gems/#{gem}/#{issue}"))
    next unless data
    if !data["cve"]
      $stderr.puts "** error: no cve information for #{issue} **"
    else
      m = data["cve"].match(/(\d\d\d\d)-.*/)
      if !m
        $stderr.puts "** error parsing date **"
        next
      end
      cve_year = Integer(m[1])
      $stderr.puts "   year: #{cve_year}"
     if cve_year == year
       counter = counter + 1
       result[data["gem"]] ||= []
       result[data["gem"]] << data["year"]
     end
    end
  end
end

puts "-------------- RESULT -------------"
result.each do |k,v|
  puts "#{k}, #{v.length}"
end
puts "TOTAL: #{counter}"

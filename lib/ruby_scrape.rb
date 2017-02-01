require 'rubygems'
require 'bundler/setup'

require 'pry'
require 'mechanize'
require 'yaml'
require 'date'

class OSVDBRuby
  attr_accessor :osvdb, :cve, :title, :description, :date, :cvss_v2, :platform, :url, :patched_versions, :page
  def initialize(url)
    self.url = url
    parse!
  end

  def parse!
    mech = Mechanize.new
    self.page = mech.get(url)

    page.search(".show_vuln_table").search("td ul li").each do |li|
      case li.children[0].text.strip
      when "CVE ID:"
        self.cve = li.children[1].text
      when "Vendor URL:"
        self.set_platform(li.children[1].text)
      end
    end

    self.description = page.search(".show_vuln_table").search("tr td tr .white_content p")[0].text
    self.date = page.search(".show_vuln_table").search("tr td tr .white_content tr td")[0].text
    self.title = page.search("title").text.gsub(/\d+: /, "")
    self.osvdb = page.search("title").text.match(/\d+/)[0]
    if cvss_p = page.search(".show_vuln_table").search("tr td tr .white_content div p")[0]
      self.set_cvss(cvss_p.children[0].text)
    end
  end

  def set_platform(vendortext)
    [/Ruby/, "mri"].each do |expr, plat|
      if vendortext.match(expr)
        self.platform = plat
      end
    end
  end

  def set_cvss(text)
    self.cvss_v2 = text.strip.gsub("CVSSv2 Base Score = ", "")
  end

  def date
    Date.parse(@date)
  end

  def cvss_v2
    @cvss_v2.nil? ? nil : @cvss_v2.to_f
  end

  def platform
    @platform.nil? ? "mri" : @platform
  end

  def to_yaml
    { 'platform' => platform,
      'cve' => cve,
      'osvdb' => osvdb.to_i,
      'url' => url,
      'title' => title,
      'date' => date,
      'description' => description,
      'cvss_v2' => cvss_v2,
      'patched_versions' => patched_versions }.to_yaml
  end

  def filename
    "OSVDB-#{osvdb}.yml"
  end

  def to_advisory!
    rubies_path = File.join(File.dirname(__FILE__), "..", "rubies")
    adv_path = File.absolute_path(File.join(rubies_path, self.platform))

    FileUtils.mkdir(adv_path) unless File.exists?(adv_path)
    File.open(File.join(adv_path, filename), "w") do |io|
      io.puts self.to_yaml
    end
  end
end

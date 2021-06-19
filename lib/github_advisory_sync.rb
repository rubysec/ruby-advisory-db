require "faraday"
require "json"
require "yaml"
require "open-uri"

module GitHub
  class GitHubAdvisorySync
    # Sync makes sure there are rubysec advisories for all GitHub advisories
    # It writes a set of yaml files, one for each GitHub Advisory that
    # is not already present in this repo
    #
    # The min_year argument specifies the earliest year CVE to sync.
    # It is more important to sync the newer ones, so this allows the user to
    # control how old of CVEs the sync should pull over
    def self.sync(min_year: 2015)
      gh_advisories = GraphQLAPIClient.new.all_rubygem_advisories

      # Filter out advisories with a CVE year that is before the min_year
      gh_advisories.select! { |v| v.cve_after_year?(min_year) }

      files_written = gh_advisories.filter_map(&:write_files).flatten.compact!

      puts "\nSync completed"
      if files_written.empty?
        puts "Nothing to sync today! All CVEs starting from #{min_year} are already present"
      else
        puts "Wrote these files:\n#{files_written.to_yaml}"
      end

      files_written
    end
  end

  class GraphQLAPIClient
    GITHUB_API_URL = "https://api.github.com/graphql".freeze

    GitHubApiTokenMissingError = Class.new(StandardError)

    # return a lazy initialized connection to github api
    def github_api(adapter = :net_http)
      @github_api ||= begin
        puts "Initializing GitHub API connection to URL: #{GITHUB_API_URL}"

        Faraday.new do |conn_builder|
          conn_builder.adapter adapter
          conn_builder.headers = {
            "User-Agent" => "rubysec/ruby-advisory-db rubysec sync script",
            "Content-Type" => "application/json",
            "Authorization" => "token #{github_api_token}"
          }
        end
      end
    end

    # An error class which gets raised when a GraphQL request fails
    GitHubGraphQLAPIError = Class.new(StandardError)

    # all interactions with the API go through this method to standardize
    # error checking and how queries and requests are formed
    def github_graphql_query(graphql_query_name, graphql_variables = {})
      graphql_query_str = GraphQLQueries.const_get graphql_query_name
      graphql_body = JSON.generate(query: graphql_query_str, variables: graphql_variables)

      puts "Executing GraphQL request: #{graphql_query_name}. Request variables:\n#{graphql_variables.to_yaml}\n"

      faraday_response = github_api.post do |req|
        req.url GITHUB_API_URL
        req.body = graphql_body
      end

      puts "Got response code: #{faraday_response.status}"

      if faraday_response.status != 200
        raise(
          GitHubGraphQLAPIError,
          "GitHub GraphQL request to #{faraday_response.env.url} failed: #{faraday_response.body}"
        )
      end

      body_obj = JSON.parse faraday_response.body

      if body_obj["errors"]
        raise(GitHubGraphQLAPIError, body_obj["errors"].map { |e| e["message"] }.join(", "))
      end

      body_obj
    end

    def all_rubygem_advisories
      advisories = {}

      retrieve_all_rubygem_vulnerabilities.each do |vulnerability|
        advisory = GitHubAdvisory.new(vulnerability["advisory"])

        next if advisory.withdrawn?

        advisories[advisory.primary_id] ||= advisory

        advisories[advisory.primary_id].vulnerabilities << vulnerability.except("advisory")
      end

      advisories.values
    end

    def retrieve_all_rubygem_vulnerabilities(max_pages = 1000, page_size = 100)
      all_vulnerabilities = []
      variables = { "first" => page_size }
      max_pages.times do |page_num|
        puts "Getting page #{page_num + 1} of GitHub Vulnerabilities"

        page = github_graphql_query(:RUBYGEM_VULNERABILITIES_WITH_GITHUB_ADVISORIES, variables)
        vulnerabilities_this_page = page["data"]["securityVulnerabilities"]["nodes"]
        all_vulnerabilities += vulnerabilities_this_page

        break unless page["data"]["securityVulnerabilities"]["pageInfo"]["hasNextPage"] == true

        variables["after"] = page["data"]["securityVulnerabilities"]["pageInfo"]["endCursor"]
      end
      puts "Retrieved #{all_vulnerabilities.length} Vulnerabilities from GitHub API"

      all_vulnerabilities
    end

    module GraphQLQueries
      RUBYGEM_VULNERABILITIES_WITH_GITHUB_ADVISORIES = <<-GRAPHQL.freeze
        query($first: Int, $after: String) {
          securityVulnerabilities(first: $first, after: $after, ecosystem:RUBYGEMS) {
            pageInfo {
              endCursor
              hasNextPage
              hasPreviousPage
              startCursor
            }
            nodes {
              package {
                name
                ecosystem
              }
              vulnerableVersionRange
              firstPatchedVersion {
                identifier
              }
              advisory {
                identifiers {
                  type
                  value
                }
                summary
                description
                severity
                cvss {
                  score
                  vectorString
                }
                references {
                  url
                }
                publishedAt
                withdrawnAt
              }
            }
          }
        }
      GRAPHQL
    end

    private

    def github_api_token
      unless ENV["GH_API_TOKEN"]
        raise(
          GitHubApiTokenMissingError,
          "Unable to make API requests.  Must define 'GH_API_TOKEN' environment variable."
        )
      end

      ENV["GH_API_TOKEN"]
    end
  end

  class GitHubAdvisory
    attr_reader :advisory, :vulnerabilities

    def initialize(advisory)
      @advisory = advisory
      @vulnerabilities = []
    end

    def identifier_list
      advisory["identifiers"]
    end

    # extract the CVE identifier from the GitHub Advisory identifier list
    def cve_id
      cve_id_obj = identifier_list.find { |id| id["type"] == "CVE" }
      return nil unless cve_id_obj

      cve_id_obj["value"]
    end

    def ghsa_id
      id_obj = identifier_list.find { |id| id["type"] == "GHSA" }
      id_obj["value"]
    end

    # advisories should be identified by CVE ID if there is one
    # but for maintainer submitted advisories there may not be one,
    # so a GitHub Security Advisory ID (ghsa_id) is used instead
    def primary_id
      return cve_id if cve_id

      ghsa_id
    end

    # return a date as a string like 2019-03-21.
    def published_day
      return unless advisory["publishedAt"]

      pub_date = Date.parse(advisory["publishedAt"])
      # pub_date.strftime("%Y-%m-%d")
      pub_date
    end

    def withdrawn?
      !advisory["withdrawnAt"].nil?
    end

    def cvss
      return "<FILL IN IF AVAILABLE>" if advisory["cvss"]["vectorString"].nil?

      advisory["cvss"]["score"].to_f
    end

    def external_reference
      advisory["references"].find do |ref|
        !ref["url"].start_with?("https://nvd.nist.gov/vuln/detail/")
      end
    end

    def package_names
      vulnerabilities.map { |v| v["package"]["name"] }.uniq
    end

    def filename_for(package_name)
      File.join("gems", package_name, "#{primary_id}.yml")
    end

    def write_files
      packages_to_write = package_names.filter { |name| !File.exist?(filename_for(name)) }

      return if packages_to_write.empty?

      packages_to_write.map do |package_name|
        filename_to_write = filename_for(package_name)

        data = {
          "gem" => package_name,
          "ghsa" => ghsa_id[5..],
          "url" => external_reference,
          "date" => published_day,
          "title" => advisory["summary"],
          "description" => advisory["description"],
          "cvss_v3" => cvss,
          "patched_versions" => ["<FILL IN SEE BELOW>"],
          "unaffected_versions" => ["<OPTIONAL: FILL IN SEE BELOW>"]
        }
        data["cve"] = cve_id[4..20] if cve_id

        dir_to_write = File.dirname(filename_to_write)
        Dir.mkdir dir_to_write unless Dir.exist?(dir_to_write)
        File.open(filename_to_write, "w") do |file|
          # create an automatically generated advisory yaml file
          file.write data.to_yaml

          # The data we just wrote is incomplete,
          # and therefore should not be committed as is
          # We can not directly translate from GitHub to rubysec advisory format
          #
          # The patched_versions field is not exactly available.
          # - GitHub has a first_patched_version field,
          #   but rubysec advisory needs a ruby version spec
          #
          # The unaffected_versions field is similarly not directly available
          # This optional field must be inferred from the vulnerableVersionRange
          #
          # To help write those fields, we put all the github data below.
          #
          # The second block of yaml in a .yaml file is ignored (after the second "---" line)
          # This effectively makes this data a large comment
          # Still it should be removed before the data goes into rubysec
          file.write "\n\n# GitHub advisory data below - **Remove this data before committing**\n"
          file.write "# Use this data to write patched_versions (and potentially unaffected_versions) above\n"
          file.write advisory.merge({ "vulnerabilities" => vulnerabilities }).to_yaml
        end
        puts "Wrote: #{filename_to_write}"
        filename_to_write
      end
    end

    def cve_after_year?(year)
      # all advisories without a CVE are included too
      return true unless cve_id

      _, cve_year = cve_id.match(/^CVE-(\d+)-\d+$/).to_a
      cve_year.to_i >= year
    end
  end
end

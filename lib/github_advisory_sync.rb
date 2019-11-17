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
      gh_advisories = GraphQLAPIClient.new.retrieve_all_rubygem_publishable_advisories

      # Filter out advisories with a CVE year that is before the min_year
      gh_advisories.select! do |advisory|
        if advisory.cve_id
          _, cve_year = advisory.cve_id.match(/^CVE-(\d+)-\d+$/).to_a
          cve_year.to_i >= min_year
        else
          true # all advisories without a CVE are included too
        end
      end

      files_written = []
      gh_advisories.each do |advisory|
        files_written += advisory.write_files
      end

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
    GITHUB_API_URL = "https://api.github.com/graphql"

    GitHubApiTokenMissingError = Class.new(StandardError)

    # return a lazy initialized connection to github api
    def github_api(adapter = :net_http)
      @faraday_connection ||= begin
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
      @faraday_connection
    end

    # An error class which gets raised when a GraphQL request fails
    GitHubGraphQLAPIError = Class.new(StandardError)

    # all interactions with the API go through this method to standardize
    # error checking and how queries and requests are formed
    def github_graphql_query(graphql_query_name, graphql_variables = {})
      graphql_query_str = GraphQLQueries.const_get graphql_query_name
      graphql_body = JSON.generate query: graphql_query_str,
                                   variables: graphql_variables
      puts "Executing GraphQL request: #{graphql_query_name}. Request variables:\n#{graphql_variables.to_yaml}\n"
      faraday_response = github_api.post do |req|
        req.url GITHUB_API_URL
        req.body = graphql_body
      end
      puts "Got response code: #{faraday_response.status}"
      if faraday_response.status != 200
        raise(GitHubGraphQLAPIError, "GitHub GraphQL request to #{faraday_response.env.url} failed: #{faraday_response.body}")
      end
      body_obj = JSON.parse faraday_response.body
      if body_obj["errors"]
        raise(GitHubGraphQLAPIError, body_obj["errors"].map { |e| e["message"] }.join(", "))
      end
      body_obj
    end

    def retrieve_all_github_advisories(max_pages = 1000, page_size = 100)
      all_advisories = []
      variables = { "first" => page_size }
      max_pages.times do |page_num|
        puts "Getting page #{page_num + 1} of GitHub Advisories"
        page = github_graphql_query(:GITHUB_ADVISORIES_WITH_RUBYGEM_VULNERABILITY, variables)
        advisories_this_page = page["data"]["securityAdvisories"]["nodes"]
        all_advisories += advisories_this_page
        break unless page["data"]["securityAdvisories"]["pageInfo"]["hasNextPage"] == true
        variables["after"] = page["data"]["securityAdvisories"]["pageInfo"]["endCursor"]
      end
      puts "Retrieved #{all_advisories.length} Advisories from GitHub API"

      all_advisories.map do |advisory_graphql_obj|
        GitHubAdvisory.new github_advisory_graphql_object: advisory_graphql_obj
      end
    end

    def retrieve_all_rubygem_publishable_advisories
      all_advisories = retrieve_all_github_advisories
      # remove withdrawn advisories,
      # and remove those where there are no vulnerabilities for ruby
      all_advisories.reject { |advisory| advisory.withdrawn? }
                    .select { |advisory| advisory.has_ruby_vulnerabilities? }
    end

    module GraphQLQueries
      GITHUB_ADVISORIES_WITH_RUBYGEM_VULNERABILITY = <<-GRAPHQL.freeze
        query($first: Int, $after: String) {
          securityAdvisories(first: $first, after: $after) {
            pageInfo {
              endCursor
              hasNextPage
              hasPreviousPage
              startCursor
            }
            nodes {
              identifiers {
                type
                value
              }
              summary
              description
              severity
              references {
                url
              }
              publishedAt
              withdrawnAt
              vulnerabilities(ecosystem:RUBYGEMS, first: 10) {
                nodes {
                  package {
                    name
                    ecosystem
                  }
                  vulnerableVersionRange
                  firstPatchedVersion {
                    identifier
                  }
                }
              }
            }
          }
        }
      GRAPHQL
    end

    private

    def github_api_token
      unless ENV["GH_API_TOKEN"]
        raise GitHubApiTokenMissingError, "Unable to make API requests.  Must define 'GH_API_TOKEN' environment variable."
      end
      ENV["GH_API_TOKEN"]
    end
  end

  class GitHubAdvisory

    attr_reader :github_advisory_graphql_object

    def initialize(github_advisory_graphql_object:)
      @github_advisory_graphql_object = github_advisory_graphql_object
    end

    def identifier_list
      github_advisory_graphql_object["identifiers"]
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
      return nil unless github_advisory_graphql_object["publishedAt"]

      pub_date = Date.parse(github_advisory_graphql_object["publishedAt"])
      # pub_date.strftime("%Y-%m-%d")
      pub_date
    end

    def package_names
      github_advisory_graphql_object["vulnerabilities"]["nodes"].map{|v| v["package"]["name"]}.uniq
    end

    def rubysec_filenames
      package_names.map do |package_name|
        File.join("gems", package_name, "#{cve_id}.yml")
      end
    end

    def withdrawn?
      !github_advisory_graphql_object["withdrawnAt"].nil?
    end

    def external_reference
      github_advisory_graphql_object["references"].first["url"]
    end

    def vulnerabilities
      github_advisory_graphql_object["vulnerabilities"]["nodes"]
    end

    def has_ruby_vulnerabilities?
      vulnerabilities.any? do |vuln|
        vuln["package"]["ecosystem"] == "RUBYGEMS"
      end
    end

    def some_rubysec_files_do_not_exist?
      rubysec_filenames.any?{|filename| !File.exist?(filename) }
    end

    def write_files
      return [] unless some_rubysec_files_do_not_exist?

      files_written = []
      vulnerabilities.each do |vulnerability|
        filename_to_write = File.join("gems", vulnerability["package"]["name"], "#{primary_id}.yml")
        next if File.exist?(filename_to_write)

        data = {
          "gem" => vulnerability["package"]["name"],
          "ghsa" => ghsa_id[5..],
          "url" => external_reference,
          "date" => published_day,
          "title" => github_advisory_graphql_object["summary"],
          "description" => github_advisory_graphql_object["description"],
          "cvss_v3" => "<FILL IN IF AVAILABLE>",
          "patched_versions" => [ "<FILL IN SEE BELOW>" ],
          "unaffected_versions" => [ "<OPTIONAL: FILL IN SEE BELOW>" ]
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
          # The unnaffected_versions field is similarly not directly available
          # This optional field must be inferred from the vulnerableVersionRange
          #
          # To help write those fields, we put all the github data below.
          #
          # The second block of yaml in a .yaml file is ignored (after the second "---" line)
          # This effectively makes this data a large comment
          # Still it should be removed before the data goes into rubysec
          file.write "\n\n# GitHub advisory data below - **Remove this data before committing**\n"
          file.write "# Use this data to write patched_versions (and potentially unaffected_versions) above\n"
          file.write github_advisory_graphql_object.to_yaml
        end
        puts "Wrote: #{filename_to_write}"
        files_written << filename_to_write
      end

      files_written
    end
  end
end

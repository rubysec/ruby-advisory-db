require "faraday"
require "json"
require "yaml"

module GitHub
  class GitHubAdvisorySync
    def self.sync
      gh_api_client = GraphQLAPIClient.new
      gh_advisories = gh_api_client.retrieve_all_rubygem_publishable_advisories

      files_written = []
      gh_advisories.each do |advisory|
        files_written += advisory.write_files
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
      # puts "Response body string:\n---#{faraday_response.body}\n---"
      if faraday_response.status != 200
        raise(GitHubGraphQLAPIError, "GitHub GraphQL request to #{faraday_response.env.url} failed: #{faraday_response.body}")
      end
      body_obj = JSON.parse faraday_response.body
      if body_obj["errors"]
        raise(GitHubGraphQLAPIError, body_obj["errors"].map { |e| e["message"] }.join(", "))
      end
      # puts "Query was successful. Response body:\n#{JSON.pretty_generate(body_obj)}\n"
      body_obj
    end

    def retrieve_all_github_advisories(max_pages = 50, page_size = 100) # up to 5K
      all_advisories = []
      variables = { "first" => page_size }
      max_pages.times do |page_num|
        puts "Getting page #{page_num + 1} of GitHub Advisories"
        page = github_graphql_query(:GITHUB_ADVISORIES_WITH_RUBYGEM_VULNERABILITY, variables)
        advisories_this_page = page["data"]["securityAdvisories"]["nodes"]
        puts "found #{advisories_this_page.length} advisories on page #{page_num}"
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
      # remove withdrawn advisories, and remove those where there are no vulnerabilities.
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

    def cve_id
      cve_id_obj = github_advisory_graphql_object["identifiers"].find{ |id| id["type"] == "CVE" }
      return nil unless cve_id_obj
      cve_id_obj["value"]
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
      return [] unless cve_id
      return [] unless some_rubysec_files_do_not_exist?

      files_written = []
      vulnerabilities.each do |vulnerability|
        filename_to_write = File.join("gems", vulnerability["package"]["name"], "#{cve_id}.yml")
        next if File.exist?(filename_to_write)

        data = {
          gem: vulnerability["package"]["name"],
          cve: cve_id[4..20],
          date: github_advisory_graphql_object["publishedAt"],
          url: external_reference,
          title: github_advisory_graphql_object["summary"],
          description: github_advisory_graphql_object["description"],
        }

        dir_to_write = File.dirname(filename_to_write)
        Dir.mkdir dir_to_write unless Dir.exist?(dir_to_write)
        File.open(filename_to_write, "w") do |file|
          file.write data.to_yaml
        end
        puts "Wrote: #{filename_to_write}"
        files_written << filename_to_write
      end

      files_written
    end

  end
end

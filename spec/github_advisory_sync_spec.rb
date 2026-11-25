require "spec_helper"
require "github_advisory_sync"

RSpec.describe GitHub::GitHubAdvisory do
  describe ".formatted_yaml" do
    it "indents generated sequence values under their keys" do
      data = {
        "patched_versions" => [">= 3.0.1"],
        "related" => {
          "url" => [
            "https://github.com/autolab/Autolab/security/advisories/GHSA-v46j-h43h-rwrm"
          ]
        }
      }

      yaml = described_class.formatted_yaml(data)

      expect(yaml).to include(%(patched_versions:\n  - ">= 3.0.1"\n))
      expect(yaml).to include(
        "related:\n" \
        "  url:\n" \
        "    - https://github.com/autolab/Autolab/security/advisories/GHSA-v46j-h43h-rwrm\n"
      )
      expect(YAML.safe_load(yaml)).to eq(data)
    end

    it "keeps nested array payloads valid" do
      data = {
        "description" => "Impact:\n- user-provided bullet\n",
        "notes" => "  heading:\n  - keep literal bullet\n",
        "vulnerabilities" => [
          {
            "package" => {
              "name" => "autolab"
            },
            "identifiers" => [
              {
                "type" => "CVE",
                "value" => "CVE-2026-1234"
              }
            ]
          }
        ]
      }

      yaml = described_class.formatted_yaml(data)

      expect(yaml).to include(
        "vulnerabilities:\n" \
        "  - package:\n" \
        "      name: autolab\n" \
        "    identifiers:\n" \
        "      - type: CVE\n" \
        "        value: CVE-2026-1234\n"
      )
      expect(YAML.safe_load(yaml)).to eq(data)
    end

    it "does not corrupt multiline quoted scalar payloads" do
      data = {
        "vulnerabilities" => [
          {
            "desc" => "x\n",
            "fixed" => true
          }
        ]
      }

      yaml = described_class.formatted_yaml(data)

      expect(YAML.safe_load(yaml)).to eq(data)
    end
  end

  # Each line pairs a vulnerable range with its first patched version (nil when GitHub lists none).
  def generated(field, gem_name, lines)
    advisory = described_class.new({})

    lines.each do |vulnerable_range, first_patched|
      advisory.vulnerabilities << {
        "package" => { "name" => gem_name },
        "vulnerableVersionRange" => vulnerable_range,
        "firstPatchedVersion" => first_patched && { "identifier" => first_patched }
      }
    end

    advisory.public_send("#{field}_for", described_class::Package.new(advisory, gem_name))
  end

  describe "#patched_versions_for" do
    it "keeps later minors of an older major patched when the next range starts at the next major" do
      expect(generated(:patched_versions, "avo", "< 3.33.1" => "3.33.1", ">= 4.0.0.beta.1, < 4.3.1" => "4.3.1"))
        .to eq(["~> 3.33, >= 3.33.1", ">= 4.3.1"])
    end

    it "keeps a later minor flagged when a vulnerable range without a fix starts inside the major" do
      expect(generated(:patched_versions, "avo", "< 3.33.1" => "3.33.1", "= 3.40.0" => nil,
                                                 ">= 4.0.0.beta.1, < 4.3.1" => "4.3.1"))
        .to eq(["~> 3.33.1", ">= 4.3.1"])
    end

    {
      "starts below the fix and ends above it" => ">= 3.10.0, <= 3.40.0",
      "has no lower bound and ends above it" => "< 4.0.0",
      "starts below the fix and never ends" => ">= 3.10.0"
    }.each do |shape, overlapping_range|
      it "keeps a later minor flagged when another vulnerable range #{shape}" do
        expect(generated(:patched_versions, "avo", "< 3.33.1" => "3.33.1", overlapping_range => nil,
                                                   ">= 4.0.0.beta.1, < 4.3.1" => "4.3.1"))
          .to eq(["~> 3.33.1", ">= 4.3.1"])
      end
    end

    it "does not widen a four-segment fix, which later releases can predate" do
      expect(generated(:patched_versions, "cgi", "< 0.1.0.2" => "0.1.0.2", ">= 1.0.0, < 1.0.5" => "1.0.5"))
        .to eq(["~> 0.1.0.2", ">= 1.0.5"])
    end

    it "does not widen a prerelease fix, which sorts below its own minor" do
      expect(generated(:patched_versions, "avo", "< 3.0.rc1" => "3.0.rc1", ">= 4.0.0, < 4.3.1" => "4.3.1"))
        .to eq(["~> 3.0.rc1", ">= 4.3.1"])
    end

    it "leaves a release line flagged when GitHub lists no fix for it" do
      expect(generated(:patched_versions, "activerecord", ">= 2.3.0, < 2.3.18" => "2.3.18",
                                                          ">= 3.1.0, < 3.1.12" => "3.1.12",
                                                          ">= 3.2.0, < 3.2.13" => "3.2.13"))
        .to eq(["~> 2.3.18", "~> 3.1.12", ">= 3.2.13"])
    end

    it "keeps the prereleases of the next minor flagged" do
      expect(generated(:patched_versions, "recurly", "< 2.0.13" => "2.0.13", ">= 2.1.0.beta1, < 2.1.11" => "2.1.11"))
        .to eq(["~> 2.0.13", ">= 2.1.11"])
    end

    it "stops before a vulnerable range that starts in the same minor" do
      expect(generated(:patched_versions, "bundler", "< 2.2.10" => "2.2.10", ">= 2.2.11, < 2.2.18" => "2.2.18"))
        .to eq([">= 2.2.10, < 2.2.11", ">= 2.2.18"])
    end

    it "stops before a single vulnerable version in the same minor" do
      expect(generated(:patched_versions, "bundler", "< 2.2.10" => "2.2.10", "= 2.2.12" => nil,
                                                     ">= 3.0.0, < 3.0.2" => "3.0.2"))
        .to eq([">= 2.2.10, < 2.2.12", ">= 3.0.2"])
    end

    it "includes the bound itself when the next range starts after it" do
      expect(generated(:patched_versions, "bundler", "< 2.2.10" => "2.2.10", "> 2.2.12, < 2.2.18" => "2.2.18"))
        .to eq([">= 2.2.10, <= 2.2.12", ">= 2.2.18"])
    end

    it "orders release lines by version, so 2.10 comes after 2.9" do
      expect(generated(:patched_versions, "recurly", ">= 2.10.0, < 2.10.4" => "2.10.4", ">= 2.9.0, < 2.9.2" => "2.9.2"))
        .to eq(["~> 2.9.2", ">= 2.10.4"])
    end

    it "keeps the plain constraints when RubyGems cannot parse a range bound" do
      expect(generated(:patched_versions, "avo", "< 3.33.1" => "3.33.1", ">= v4.0.0, < 4.3.1" => "4.3.1"))
        .to eq(["~> 3.33.1", ">= 4.3.1"])
    end

    it "keeps the plain constraints when RubyGems cannot parse an older fix" do
      expect(generated(:patched_versions, "avo", "< 1.0.0" => "1.0.0-x86_64-linux", ">= 2.0.0, < 2.0.3" => "2.0.3",
                                                 ">= 3.0.0, < 3.0.1" => "3.0.1"))
        .to eq(["~> 1.0.0-x86_64-linux", "~> 2.0.3", ">= 3.0.1"])
    end

    it "keeps the plain constraints when RubyGems cannot parse the newest fix" do
      expect(generated(:patched_versions, "avo", "< 3.33.1" => "3.33.1", ">= 4.0.0, <= 4.3.0" => "v4.3.1"))
        .to eq(["~> 3.33.1", ">= v4.3.1"])
    end

    it "reads only the release lines of the gem it is asked about" do
      advisory = described_class.new({})
      { "solidus_api" => "2.8.6", "solidus_core" => "3.0.1" }.each do |gem_name, first_patched|
        advisory.vulnerabilities << {
          "package" => { "name" => gem_name },
          "vulnerableVersionRange" => "< #{first_patched}",
          "firstPatchedVersion" => { "identifier" => first_patched }
        }
      end

      expect(advisory.patched_versions_for(described_class::Package.new(advisory, "solidus_api")))
        .to eq([">= 2.8.6"])
    end
  end

  describe "#unaffected_versions_for" do
    it "starts at the oldest vulnerable range by version, so 1.8 comes before 1.12" do
      expect(generated(:unaffected_versions, "ember-source", ">= 1.12.0, < 1.12.2" => "1.12.2",
                                                             ">= 1.8.0, < 1.11.4" => "1.11.4"))
        .to eq(["< 1.8.0"])
    end

    it "lists nothing when a vulnerable range has no lower bound" do
      expect(generated(:unaffected_versions, "avo", "<= 0.10.1" => "0.10.2", "> 0.9.0" => nil)).to be_nil
    end

    it "counts a single vulnerable version as a start" do
      expect(generated(:unaffected_versions, "avo", "= 2.0.0" => nil, ">= 1.0.0, < 1.5.0" => "1.5.0"))
        .to eq(["< 1.0.0"])
    end

    it "lists nothing when RubyGems cannot parse a range start" do
      expect(generated(:unaffected_versions, "avo", ">= 1.0.0, < 1.0.5" => "1.0.5", ">= 0.5.0+build, < 0.5.3" => nil))
        .to be_nil
    end

    it "leaves a start vulnerable when one range starts at it and another right after it" do
      expect(generated(:unaffected_versions, "avo", "> 1.0.0, < 1.0.5" => "1.0.5", "= 1.0" => "1.0.1"))
        .to eq(["< 1.0"])
    end
  end
end

RSpec.describe GitHub::GitHubAdvisorySync do
  describe ".sync" do
    def sync_with(results)
      advisories = results.map do |files|
        instance_double(GitHub::GitHubAdvisory, cve_after_year?: true, sync: files)
      end
      client = instance_double(GitHub::GraphQLAPIClient, all_rubygem_advisories: advisories)
      allow(GitHub::GraphQLAPIClient).to receive(:new).and_return(client)

      silence_output { described_class.sync }
    end

    def silence_output
      original = $stdout
      $stdout = StringIO.new
      yield
    ensure
      $stdout = original
    end

    it "returns the files written when every advisory changed a file" do
      expect(sync_with([["gems/a/CVE-1.yml"], ["gems/b/CVE-2.yml"]]))
        .to eq(["gems/a/CVE-1.yml", "gems/b/CVE-2.yml"])
    end

    it "ignores advisories that left their files unchanged" do
      expect(sync_with([[nil], ["gems/b/CVE-2.yml"]])).to eq(["gems/b/CVE-2.yml"])
    end

    it "returns an empty list when nothing changed" do
      expect(sync_with([[nil], [nil]])).to eq([])
    end

    it "returns an empty list when GitHub has no advisories" do
      expect(sync_with([])).to eq([])
    end
  end
end

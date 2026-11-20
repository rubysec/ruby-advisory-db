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

  describe "#patched_versions_for" do
    def patched_versions_for(gem_name, lines)
      advisory = described_class.new({})

      lines.each do |vulnerable_range, first_patched|
        advisory.vulnerabilities << {
          "package" => { "name" => gem_name },
          "vulnerableVersionRange" => vulnerable_range,
          "firstPatchedVersion" => { "identifier" => first_patched }
        }
      end

      advisory.patched_versions_for(described_class::Package.new(advisory, gem_name))
    end

    it "keeps later minors of an older major patched when the next range starts at the next major" do
      patched_versions = patched_versions_for(
        "avo",
        "< 3.33.1" => "3.33.1",
        ">= 4.0.0.beta.1, < 4.3.1" => "4.3.1"
      )

      expect(patched_versions).to eq(["~> 3.33, >= 3.33.1", ">= 4.3.1"])
    end

    it "leaves a release line flagged when GitHub lists no fix for it" do
      patched_versions = patched_versions_for(
        "activerecord",
        ">= 2.3.0, < 2.3.18" => "2.3.18",
        ">= 3.1.0, < 3.1.12" => "3.1.12",
        ">= 3.2.0, < 3.2.13" => "3.2.13"
      )

      expect(patched_versions).to eq(["~> 2.3.18", "~> 3.1.12", ">= 3.2.13"])
    end

    it "stops before a vulnerable range that starts in the same minor" do
      patched_versions = patched_versions_for(
        "bundler",
        "< 2.2.10" => "2.2.10",
        ">= 2.2.11, < 2.2.18" => "2.2.18"
      )

      expect(patched_versions).to eq([">= 2.2.10, < 2.2.11", ">= 2.2.18"])
    end

    it "orders release lines by version, so 2.10 comes after 2.9" do
      patched_versions = patched_versions_for(
        "recurly",
        ">= 2.10.0, < 2.10.4" => "2.10.4",
        ">= 2.9.0, < 2.9.2" => "2.9.2"
      )

      expect(patched_versions).to eq(["~> 2.9.2", ">= 2.10.4"])
    end
  end
end

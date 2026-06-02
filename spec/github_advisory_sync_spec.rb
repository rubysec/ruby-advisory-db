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
end

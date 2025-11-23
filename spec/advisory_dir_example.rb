require 'rspec'
require 'date'

shared_examples_for "Advisory Directory" do |dir|
  describe dir do
    let(:advisory_paths) { Dir.glob(File.join(dir,'*.yml')) }
    let(:advisories) do
      advisory_paths.map do |path|
        YAML.safe_load_file(path, permitted_classes: [Date])
      end
    end

    it "must not contain duplicate CVE IDs" do
      cve_ids = advisories.map { |advisory| advisory['cve'] }
      cve_ids.compact!

      expect(cve_ids).to eq(cve_ids.uniq)
    end

    it "must not contain duplicate GHSA IDs" do
      ghsa_ids = advisories.map { |advisory| advisory['ghsa'] }.compact
      ghsa_ids.compact!

      expect(ghsa_ids).to match_array(ghsa_ids.uniq)
    end
  end
end

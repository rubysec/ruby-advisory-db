# Contributing Guidelines

* Try to keep all text within 80 columns.
* YAML must be indented by 2 spaces.
* Please see the [README](README.md#schema) for more documentation on the
  YAML Schema.
* `title:` must be a single sentence/line.
* `description: |` must contain more than one sentence/line.
* Values for `cvss_v2`, `cvss_v3`, and `cvss_v4` can be found in the reference URLs from [nvd.nist.gov](https://nvd.nist.gov/vuln/search#/nvd/home?resultType=records), [GHSA Advisories](https://github.com/advisories),  and the repo's security advisory.
* `patched_versions`/`unaffected_versions` version ranges must be quoted
  (ex: `">= 1.2.3"`).
* Prior to submitting a pull request,
  * Run [yamlint](https://yamllint.readthedocs.io/en/stable/quickstart.html] to check yaml format
  * Run the tests:

```
bundle install
bundle exec rspec
```

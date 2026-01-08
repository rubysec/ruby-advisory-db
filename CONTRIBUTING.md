# Contributing Guidelines

* Try to keep all text within 80 columns.
* `title:` must be a single sentence/line.
* `description: |` must contain more than one sentence/line.
* `patched_versions`/`unaffected_versions` version ranges must be quoted
  (ex: `">= 1.2.3"`).
* Values for 'cvss_v2', 'cvss_v3', and 'cvss_v4' can be found in
  the reference URLs from nvd.nist.gov, https://github.com/advisories,
  and the repo's security advisory.
* Prior to submitting a pull request, 
  * Run yamlint to check yaml format
    * https://yamllint.readthedocs.io/en/stable
    * YAML must be indented by 2 spaces.
    * Please see the [README](README.md#schema) for more documentation on the
      YAML Schema.
  * Run the tests and see that it is clean:

```
bundle install
bundle exec rspec
```

# Contributing Guidelines

* Try to keep all text within 80 columns.
* YAML must be indented by 2 spaces.
* `title:` must be a single sentence/line.
* `description: |` must contain more than one sentence/line.
* `patched_versions`/`unaffected_versions` version ranges must be quoted
  (ex: `">= 1.2.3"`).
* Please see the [README](README.md#schema) for more documentation on the
  YAML Schema.
* Prior to submitting a pull request, run the tests:

```
bundle install
bundle exec rspec
```

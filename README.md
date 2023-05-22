# Ruby Advisory Database

The Ruby Advisory Database is a community effort to compile all security advisories that are relevant to Ruby libraries.

You can check your own Gemfile.locks against this database by using [bundler-audit](https://github.com/rubysec/bundler-audit).

## Support Ruby security!

Do you know about a vulnerability that isn't listed in this database? Open an issue or submit a PR.

## Directory Structure

The database is a list of directories that match the names of Ruby libraries on
[rubygems.org]. Within each directory are one or more advisory files
for the Ruby library. These advisory files are named using
the advisories' [CVE] identifier number.

```
gems/:
  actionpack/:
    CVE-2014-0130.yml  CVE-2014-7818.yml  CVE-2014-7829.yml  CVE-2015-7576.yml
    CVE-2015-7581.yml  CVE-2016-0751.yml  CVE-2016-0752.yml
rubies/:
  jruby/:
    ...
  mruby/:
    ...
  ruby/:
    ...
```

### `gems/`

The `gems/` directory contains sub-directories that match the names of the Ruby
libraries on [rubygems.org]. Within each directory are one or more advisory
files for the Ruby library. These advisory files are named using the
advisories' [CVE] or [GHSA] ID.

### `rubies/`

The `rubies/` directory contains sub-directories for each Ruby implementation.
Within each directory are one or more advisory files for the Ruby
implementation. These advisory files are named using the advisories' [CVE]
or [GHSA] ID.

## Format

Each advisory file contains the advisory information in [YAML] format.
Here are some example advisories:

### `gems/actionpack/CVE-2023-22797.yml`

```yaml
---
gem: actionpack
cve: 2023-22797
ghsa: 9445-4cr6-336r
url: https://github.com/rails/rails/releases/tag/v7.0.4.1
title: Open Redirect Vulnerability in Action Pack
date: 2023-01-18
description: |
  There is a vulnerability in Action Controller’s redirect_to. This
  vulnerability has been assigned the CVE identifier CVE-2023-22797.

  Versions Affected: >= 7.0.0
  Not affected: < 7.0.0
  Fixed Versions: 7.0.4.1

  # Impact

  There is a possible open redirect when using the redirect_to helper with
  untrusted user input.

  Vulnerable code will look like this:
  \`\`\`
  redirect_to(params[:some_param])
  \`\`\`

  Rails 7.0 introduced protection against open redirects from calling
  redirect_to with untrusted user input. In prior versions the developer was
  fully responsible for only providing trusted input. However the check
  introduced could be bypassed by a carefully crafted URL.

  All users running an affected release should either upgrade or use one of
  the workarounds immediately.

  # Workarounds

  There are no feasible workarounds for this issue.
cvss_v3: 6.1
unaffected_versions:
  - "< 7.0.0"
patched_versions:
  - ">= 7.0.4.1"
```

### `rubies/ruby/CVE-2022-28739.yml`

```
---
engine: ruby
cve: 2022-28739
url: https://www.ruby-lang.org/en/news/2022/04/12/buffer-overrun-in-string-to-float-cve-2022-28739/
title: Buffer overrun in String-to-Float conversion
date: 2022-04-12
description: |
  A buffer-overrun vulnerability is discovered in a conversion algorithm from a String to a Float. This vulnerability has been assigned the CVE identifier CVE-2022-28739. We strongly recommend upgrading Ruby.

  Due to a bug in an internal function that converts a String to a Float, some convertion methods like Kernel#Float and String#to_f could cause buffer over-read. A typical consequence is a process termination due to segmentation fault, but in a limited circumstances, it may be exploitable for illegal memory read.

  Please update Ruby to 2.6.10, 2.7.6, 3.0.4, or 3.1.2.
patched_versions:
  - ~> 2.6.10
  - ~> 2.7.6
  - ~> 3.0.4
  - '>= 3.1.2'
```

## Schema

### `gems`

* `gem` \[String\] (required): Name of the affected gem.
* `library` \[String\] (optional): Name of the ruby library which the affected gem belongs to.
* `framework` \[String\] (optional): Name of the framework which the affected gem belongs to.
* `platform` \[String\] (optional): If this vulnerability is platform-specific, name of platform this vulnerability affects (e.g. jruby)
* `cve` \[String\] (optional): Common Vulnerabilities and Exposures (CVE) ID.
* `osvdb` \[Integer\] (optional): Open Sourced Vulnerability Database (OSVDB) ID.
* `ghsa` \[String\] (optional): GitHub Security Advisory (GHSA) ID.
* `url` \[String\] (required): The URL to the full advisory.
* `title` \[String\] (required): The title of the advisory or individual vulnerability. It must be a single line sentence.
* `date` \[Date\] (required): The public disclosure date of the advisory.
* `description` \[String\] (required): One or more paragraphs describing the vulnerability. It may contain multiple paragraphs.
* `cvss_v2` \[Float\] (optional): The [CVSSv2] score for the vulnerability.
* `cvss_v3` \[Float\] (optional): The [CVSSv3] score for the vulnerability.
* `unaffected_versions` \[Array\<String\>\] (optional): The version requirements for the
  unaffected versions of the Ruby library.
* `patched_versions` \[Array\<String\>\] (optional): The version requirements for the
  patched versions of the Ruby library.
* `related` \[Hash\<Array\<String\>\>\] (optional): Sometimes an advisory references many urls and other identifiers. Supported keys: `cve`, `ghsa`, `osvdb`, and `url`
* `notes` \[String\] (optional): Internal notes regarding the vulnerability's inclusion in this database.

### `rubies`

* `engine` \[`ruby` | `mruby` | `jruby` | `truffleruby`\] (required): Name of the affected Ruby implementation.
* `platform` \[String\] (optional): If this vulnerability is platform-specific, name of platform this vulnerability affects (e.g. jruby)
* `cve` \[String\] (optional): Common Vulnerabilities and Exposures (CVE) ID.
* `osvdb` \[Integer\] (optional): Open Sourced Vulnerability Database (OSVDB) ID.
* `ghsa` \[String\] (optional): GitHub Security Advisory (GHSA) ID.
* `url` \[String\] (required): The URL to the full advisory.
* `title` \[String\] (required): The title of the advisory or individual vulnerability. It must be a single line sentence.
* `date` \[Date\] (required): The public disclosure date of the advisory.
* `description` \[String\] (required): One or more paragraphs describing the vulnerability. It may contain multiple paragraphs.
* `cvss_v2` \[Float\] (optional): The [CVSSv2] score for the vulnerability.
* `cvss_v3` \[Float\] (optional): The [CVSSv3] score for the vulnerability.
* `unaffected_versions` \[Array\<String\>\] (optional): The version requirements for the
  unaffected versions of the Ruby implementation.
* `patched_versions` \[Array\<String\>\] (optional): The version requirements for the
  patched versions of the Ruby implementation.
* `related` \[Hash\<Array\<String\>\>\] (optional): Sometimes an advisory references many urls and other identifiers. Supported keys: `cve`, `ghsa`, `osvdb`, and `url`
* `notes` \[String\] (optional): Internal notes regarding the vulnerability's inclusion in this database.

[CVSSv2]: https://www.first.org/cvss/v2/guide
[CVSSv3]: https://www.first.org/cvss/user-guide

### Tests

Prior to submitting a pull request, run the tests:

```
bundle install
bundle exec rspec
```

### GitHub Advisory Sync

There is a script that will create initial yaml files for RubyGem advisories which
are in the [GitHub Security Advisory API](https://developer.github.com/v4/object/securityadvisory/),
but are not already in this dataset.  This script can be periodically run to ensure
this repo has all the data that is present in the GitHub Advisory data.

The GitHub Advisory API requires a token to access it.
- It can be a completely scopeless token (recommended); it does not require any permissions at all.
- Get yours at https://github.com/settings/tokens

To run the GitHub Advisory sync to retrieve all advisories, start by executing the rake task:

```
GH_API_TOKEN=<your GitHub API Token> bundle exec rake sync_github_advisories
```

Or, to only retrieve advisories for a single gem:

```
GH_API_TOKEN=<your GitHub API Token> bundle exec rake sync_github_advisories[gem_name]
```

- The rake task will write yaml files for any missing advisories.
- Those files must be further edited.
  - Fill in `cvss_v3` field by following the CVE link and getting it from page
  - Fill in `patched_versions` field, using the comments at the bottom of the file
  - Fill in `unaffected_versions`, optional, if there are unaffected_versions
  - delete the GitHub data at the bottom of the yaml file
  - double check all the data, commit it, and make a PR
    - *The GitHub Advisory data is structured opposite of RubySec unfortunately:
       GitHub identifies version range which are vulnerable; RubySec identifies
      version ranges which are not vulnerable.  This is why some manual
      work to translate is needed.*


## Credits

Please see [CONTRIBUTORS.md].

This database also includes data from the [Open Sourced Vulnerability Database][OSVDB]
developed by the Open Security Foundation (OSF) and its contributors.

[rubygems.org]: https://rubygems.org/
[CVE]: https://cve.mitre.org/
[OSVDB]: https://en.wikipedia.org/wiki/Open_Source_Vulnerability_Database
[GHSA]: https://help.github.com/en/articles/about-maintainer-security-advisories
[CVSSv2]: https://www.first.org/cvss/v2/guide
[CVSSv3]: https://www.first.org/cvss/user-guide
[YAML]: http://www.yaml.org/
[CONTRIBUTORS.md]: https://github.com/rubysec/ruby-advisory-db/blob/master/CONTRIBUTORS.md

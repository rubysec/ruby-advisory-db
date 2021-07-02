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

    gems/:
      actionpack/:
        CVE-2014-0130.yml  CVE-2014-7818.yml  CVE-2014-7829.yml  CVE-2015-7576.yml
        CVE-2015-7581.yml  CVE-2016-0751.yml  CVE-2016-0752.yml

## Format

Each advisory file contains the advisory information in [YAML] format:

    ---
    gem: examplegem
    cve: 2013-0156
    date: 2013-05-01
    url: https://github.com/rubysec/ruby-advisory-db/issues/123456
    title: |
      Ruby on Rails params_parser.rb Action Pack Type Casting Parameter Parsing
      Remote Code Execution

    description: |
      Ruby on Rails contains a flaw in params_parser.rb of the Action Pack.
      The issue is triggered when a type casting error occurs during the parsing
      of parameters. This may allow a remote attacker to potentially execute
      arbitrary code.

    cvss_v2: 10.0
    cvss_v3: 9.8

    patched_versions:
      - ~> 2.3.15
      - ~> 3.0.19
      - ~> 3.1.10
      - ">= 3.2.11"
    unaffected_versions:
      - ~> 2.4.3

    related:
      cve:
        - 2013-1234567
        - 2013-1234568
      url:
        - https://github.com/rubysec/ruby-advisory-db/issues/123457


### Schema

* `gem` \[String\] (required): Name of the affected gem.
* `library` \[String\] (optional): Name of the ruby library which the affected gem belongs to.
* `framework` \[String\] (optional): Name of the framework which the affected
  gem belongs to.
* `platform` \[String\] (optional): If this vulnerability is platform-specific, name of platform this vulnerability affects (e.g. jruby)
* `cve` \[String\] (optional): Common Vulnerabilities and Exposures (CVE) ID.
* `osvdb` \[Integer\] (optional): Open Sourced Vulnerability Database (OSVDB) ID.
* `ghsa` \[String\] (optional): GitHub Security Advisory (GHSA) ID.
* `url` \[String\] (required): The URL to the full advisory.
* `title` \[String\] (required): The title of the advisory or individual vulnerability.
* `date` \[Date\] (required): The public disclosure date of the advisory.
* `description` \[String\] (required): One or more paragraphs describing the vulnerability.
* `cvss_v2` \[Float\] (optional): The [CVSSv2] score for the vulnerability.
* `cvss_v3` \[Float\] (optional): The [CVSSv3] score for the vulnerability.
* `unaffected_versions` \[Array\<String\>\] (optional): The version requirements for the
  unaffected versions of the Ruby library.
* `patched_versions` \[Array\<String\>\] (optional): The version requirements for the
  patched versions of the Ruby library.
* `related` \[Hash\<Array\<String\>\>\] (optional): Sometimes an advisory references many urls and other identifiers. Supported keys: `cve`, `ghsa`, `osvdb`, and `url`
* `notes` \[String\] (optional): Internal notes regarding the vulnerability's inclusion in this database.

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

To run the GitHub Advisory sync, start by executing the rake task:
```
GH_API_TOKEN=<your GitHub API Token> bundle exec rake sync_github_advisories
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
[OSVDB]: http://www.osvdb.org/
[GHSA]: https://help.github.com/en/articles/about-maintainer-security-advisories
[CVSSv2]: https://www.first.org/cvss/v2/guide
[CVSSv3]: https://www.first.org/cvss/user-guide
[YAML]: http://www.yaml.org/
[CONTRIBUTORS.md]: https://github.com/rubysec/ruby-advisory-db/blob/master/CONTRIBUTORS.md

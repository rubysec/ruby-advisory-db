# Ruby Advisory Database

The Ruby Advisory Database is a community effort to compile all security
 advisories that are relevant to Ruby libraries and language dialects.

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

The database also include a list of directories for the supported
(jruby, mruby, rbx, and ruby) Ruby dialects. Within each directory
are one or more advisory files for the Ruby dialects. These advisory
files are named using the advisories' [CVE] identifier number.

    rubies/:
      ruby/:
        CVE-2008-3657.yml  CVE-2011-3009.yml  CVE-2014-8080.yml  CVE-2018-8777.yml
        CVE-2008-3790.yml  CVE-2011-3389.yml  CVE-2014-8090.yml  CVE-2018-8778.yml

## Format

Each advisory file contains the advisory information in [YAML] format.
Follow the schema. Here is an example advisory for a Ruby library:

```yaml
    ---
    gem: examplegem
    cve: 2013-0156
    date: 2013-05-01
    url: https://github.com/rubysec/ruby-advisory-db/issues/123456
    title:
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
```

 Here is an example advisory for Ruby dialect:
AL>>
```yaml
    ---
    engine: ruby
    cve: 2018-16395
    url: https://www.ruby-lang.org/en/news/2018/10/17/openssl-x509-name-equality-check-does-not-work-correctly-cve-2018-16395/
    title: Incorrect equality check in OpenSSL::X509::Name
    date: 2018-10-17

    description: |
      The equality check of `OpenSSL::X509::Name` is not correctly in openssl
      extension library bundled with Ruby.

      An instance of `OpenSSL::X509::Name` contains entities such as `CN`, `C`
      and so on. Some two instances of `OpenSSL::X509::Name` are equal only when
      all entities are exactly equal. However, there is a bug that the equality
      check is not correct if the value of an entity of the argument (right-hand
      side) starts with the value of the receiver (left-hand side). So, if a
      malicious X.509 certificate is passed to compare with an existing
      certificate, there is a possibility to be judged incorrectly that they are
      equal.

      It is strongly recommended for Ruby users to upgrade your Ruby installation
      or take one of the following workarounds as soon as possible.

      `openssl` gem 2.1.2 or later includes the fix for the vulnerability, so
      upgrade `openssl` gem to the latest version if you are using Ruby 2.4 or
      later series.

      `gem install openssl -v ">= 2.1.2"`

      However, in Ruby 2.3 series, you cannot override bundled version of openssl
      with `openssl` gem. Please upgrade your Ruby installation to the latest
      version.

    patched_versions:
      - ~> 2.3.8
      - ~> 2.4.5
      - ~> 2.5.2
      - '>= 2.6.0-preview3'
```

### Schema

* `gem` \[String\] (required for libraries): Name of the affected library advisories.
* `engine` \[String\] (required for dialects): Name of the affected Ruby dialect advisories.
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
  unaffected versions of the Ruby library or dialect.
* `patched_versions` \[Array\<String\>\] (optional): The version requirements for the
  patched versions of the Ruby library or dialect.
* `related` \[Hash\<Array\<String\>\>\] (optional): Sometimes an advisory references many urls and other identifiers. Supported keys: `cve`, `ghsa`, `osvdb`, and `url`
* `notes` \[String\] (optional): Internal notes regarding the vulnerability's inclusion in this database.

[CVSSv2]: https://www.first.org/cvss/v2/guide
[CVSSv3]: https://www.first.org/cvss/user-guide
```

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

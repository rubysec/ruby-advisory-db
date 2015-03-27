# Contributing Guidelines

* All text must be within 80 columns.
* YAML must be indented by 2 spaces.
* Have any questions? Feel free to open an issue.
* Prior to submitting a pull request, run the tests:

```
bundle install
bundle exec rspec
```

* Follow the schema. Here is a sample advisory:

```yaml
    ---
    gem: activerecord
    framework: rails
    cve: 2014-3514
    url: https://groups.google.com/forum/#!msg/rubyonrails-security/M4chq5Sb540/CC1Fh0Y_NWwJ
    title: Data Injection Vulnerability in Active Record 
    date: 2014-08-18

    description: >-
      The create_with functionality in Active Record was implemented
      incorrectly and completely bypasses the strong parameters
      protection. Applications which pass user-controlled values to
      create_with could allow attackers to set arbitrary attributes on
      models.
      
    cvss_v2: 8.7

    unaffected_versions:
      - "< 4.0.0"

    patched_versions:
      - ~> 4.0.9 
      - ">= 4.1.5"
```
### Schema

* `gem` \[String\]: Name of the affected gem.
* `framework` \[String\] (optional): Name of framework gem belongs to.
* `platform` \[String\] (optional): If this vulnerability is platform-specific, name of platform this vulnerability affects (e.g. JRuby)
* `cve` \[String\]: CVE id.
* `osvdb` \[Fixnum\]: OSVDB id.
* `url` \[String\]: The URL to the full advisory.
* `title` \[String\]: The title of the advisory.
* `date` \[Date\]: Disclosure date of the advisory.
* `description` \[String\]: Multi-paragraph description of the vulnerability.
* `cvss_v2` \[Float\]: The [CVSSv2] score for the vulnerability.
* `unaffected_versions` \[Array\<String\>\] (optional): The version requirements for the
  unaffected versions of the Ruby library.
* `patched_versions` \[Array\<String\>\]: The version requirements for the
  patched versions of the Ruby library.


## Information on Helping To Improve External Data

Remember that these requests are outside the scope of the ruby-advisory-db repo.

Here are the different sources of information this repo usually uses and how to request a change if needed.

 * GENERAL
   * Missing CVE number (also just "reserved" CVE with no details)
     * Google CVE number, check cve.org and nvd.nist.gov web sites
   * Missing GHSA number
     * Google GHSA number, check [GHSA](https://github.com/advisories) web site.
   * Missing patch release
     * See [repo](https://github.com/rubysec/ruby-advisory-db) README on policy.
   * Have only project-specific data (announcement, blog, CHANGELOG, Release notes) about advisory
     * Google for more information. Try to contact developer privately.
   * To exclude a duplicate or disputed advisories, send them to @jasnow to add them to his ignored-dup-list.file.
         
 * GEMS

   * PR: To change a specific **GHSA rubygems-related** advisory, go to [GHSA](https://github.com/advisories) and search for the  specific advisory. Scroll down to the bottom of web page and  click on `See something to contribute?` link. This will open a page where you can edit the advisory and create
     a GHSA PR.

     * EXAMPLE:
       * https://github.com/github/advisory-database/pull/7717 (open)
       * https://github.com/github/advisory-database/issues/7296 (open)
       * https://github.com/github/advisory-database/issues/1796 (gave up)

   * To create a **new GHSA rubygems-advisory*, go to [HERE](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/fix-reported-vulnerabilities/creating-a-repository-security-advisory) and follow their instructions.

   * To change something on the **https://nvd.nist.gov/vuln/detail** web site, currently not known but you can read more at [HERE](https://nvd.nist.gov/general/cve-process).

   * To change something on **https://www.cve.org** as Non-CNA, got [HERE](https://www.cve.org/ReportRequest/ReportRequestForNonCNAs) and follows their directions.

   * To change something with **osvdb** advisory, the Open Sourced Vulnerability Database (OSVDB) was permanently shut down in 2016 and is no longer active or hosted online. Try to see if there is a GHSA or CVE reference that that vulnerability.

 * RUBIES (ruby, jruby, mruby, rubinius/rbx, etc) 

   * For specific GHSA ruby-related unreviewed advisory change, go to https://github.com/advisories?query=type%3Aunreviewed
     and search for the specific advisory. Scroll down to the  bottom of web page and click on "See something to contribute?" link. This will open a page where you can edit the advisory and create a GHSA PR.

   * For changes on Ruby web site, go https://github.com/ruby/www.ruby-lang.org and follow:
     * [Quick Fixes](https://github.com/ruby/www.ruby-lang.org/blob/master/README.md#quick-fixes)
     * [Making Changes](https://github.com/ruby/www.ruby-lang.org/blob/master/README.md#making-changes)

    * To add additional GHSA `ecosystem`, such for `RubyNotGem` advisories, create GHSA and osv-schema issues and/or PRs. See examples below:
      * EXAMPLES
        * https://github.com/ossf/osv-schema/pull/515 (assigned to @another-rex/gave up)
        * https://github.com/ossf/osv-schema/issues/123 (gave up)
        * https://github.com/github/advisory-database/issues/1796 (gave up)
        * https://github.com/github/advisory-database/issues/6676 (gave up)

Feel free to **suggest more scenarios to add or better words/etc to improve existing scenarios.**

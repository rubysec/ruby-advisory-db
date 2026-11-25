# My daily ruby-advisory-db (RAD) process

 1. Check current open RAD and bundler-audit (BA) issues and PRs. 
    * Review and approve BA dependabot PRs.

 2. RAD

    A. Daily Find/Share RAD advisories.
       1. Use tools under RAD's lib directory to get GHSA Review advisories.
          * github_advisory_sync.rb, rad-ignores.sh
       2. Check for GHSA unreviewed advisories.
          * https://github.com/advisories?query=type%3Aunreviewed+ruby
       3. To get advisories before GHSA publishs them
          a. Daily, monitor some common Ruby and/or Rails repos.
             FYI: "bundle update; git diff" then see review gem release notes.
          b. Subscribe to GitHub repo Security page for gems of interest.
             * Example: https://github.com/rails/rails/security/advisories
          c. Subscribe to email at bottom of web page: https://railslts.com .
       4. Also review ruby/rails RSS feeds for gem/language news.
          * Example
            * https://www.ruby-lang.org/en/feeds/news.rss
            * https://rubysec.com/atom.xml
            * https://advisories.gitlab.com (Not just ruby-based)
            * https://github.com/advisories?query=type%3Areviewed+ecosystem%3Arubygems
            * https://rubycentral.org

       5. Visualping.io is free for 150 checks/month. I used them
          for daily checks.
          * Example: https://www.ruby-lang.org/en/security
          * https://github.com/advisories?query=type%3Areviewed+ecosystem%3Arubygems

    B. Create RAD advisory files from step 1.
       * lib/mkm tool - Usage: "mkm . >> FILE.yml"

    C. Review step 2's RAD advs. Assign others to review.

    D. Merge step 3's RAD advs.

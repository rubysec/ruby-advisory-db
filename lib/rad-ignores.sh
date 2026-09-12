#!/usr/bin/env bash

echo "In rad-ignores.sh"

REPON="ruby-advisory-db"
if [ "X`pwd |sed -e "s,.*/,,"`X" == "X${REPON}X" ] ; then
    :
else
    echo "Change dir to [${REPON}] first."
    exit
fi

# 10/26/2024, 5/25/2026: Autolab is not a Rubygem so remove it.
# 7/13/2026: Found 10 more so added them here.
#https://github.com/autolab/Autolab/security/advisories/GHSA-v46j-h43h-rwrm
#https://github.com/autolab/Autolab/security/advisories/GHSA-84qc-7773-2gg3
#https://github.com/autolab/Autolab/security/advisories/GHSA-8qhp-jhhw-45r2
#https://github.com/autolab/Autolab/security/advisories/GHSA-962r-m9fj-3hj9
#https://github.com/autolab/Autolab/security/advisories/GHSA-cqxx-pfmh-h43g
#https://github.com/autolab/Autolab/security/advisories/GHSA-g7x7-mgrv-f24x
#https://github.com/autolab/Autolab/security/advisories/GHSA-h8g5-vhm4-wx6g
#https://github.com/autolab/Autolab/security/advisories/GHSA-h8wq-ghfq-5hfx
#https://github.com/autolab/Autolab/security/advisories/GHSA-rjg4-cf66-x6gr
#https://github.com/autolab/Autolab/security/advisories/GHSA-x9hj-r9q4-832c
rm -f gems/Autolab/CVE-2024-49376.yml

# 1/29/2026, 5/25/2026: rails is not a Rubygem so remove it.
#    Covered by gems/actionpack/CVE-2024-26143.yml file
rm -f gems/rails/CVE-2024-26143.yml

# Extra GHSA advisory.
# 3/31/2026, 5/25/2026: Using GHSA-46fp-8f5p-pf2m.yml so
#    GHSA-2j22-pr5w-6gq8.yml is dup.
rm -f gems/loofah/GHSA-2j22-pr5w-6gq8.yml

# Use CVE over GHSA prefix.
# 9/23/2024, 1/19/2026: 5/25/2026: Using gems/omniauth-saml/CVE-2024-45409.yml
rm -f gems/omniauth-saml/GHSA-cvp8-5r8g-fhvq.yml

# Use CVE over GHSA prefix.
# 1/29/2026, 5/25/2026; Using gems/user_agent_parser/CVE-2020-5243.yml
# https://github.com/advisories/GHSA-cmcx-xhr8-3w9p
# https://github.com/advisories/GHSA-pcqq-5962-hvcw
rm -f gems/user_agent_parser/GHSA-pcqq-5962-hvcw.yml

# Use CVE over GHSA prefix.
# 1/29/2026, 5/25/2026: Using gems/nokogiri/CVE-2021-30560.yml
#https://github.com/advisories/GHSA-fq42-c5rg-92c2
#https://github.com/advisories/GHSA-59gp-qqm7-cw4j
rm -f gems/nokogiri/GHSA-fq42-c5rg-92c2.yml

# Use CVE over GHSA prefix.
# 1/19/2026, 5/25/2026: Using gems/nokogiri/CVE-2018-25032.yml
# https://github.com/advisories/GHSA-v6gp-9mmm-c6p5
# https://github.com/advisories/GHSA-jc36-42cf-vqwj
rm -f gems/nokogiri/GHSA-v6gp-9mmm-c6p5.yml

# Use CVE over GHSA prefix.
# 1/29/2026, 5/25/2026: Using gems/nokogiri/CVE-2022-23437.yml
# https://github.com/advisories/GHSA-xxx9-3xcr-gjj3
rm -rf gems/nokogiri/GHSA-xxx9-3xcr-gjj3.yml

# Use CVE over GHSA prefix.
# 5/31/2026: gems/nokogiri/CVE-2022-24839.yml
rm -rf gems/nokogiri/GHSA-gx8x-g87m-h5q6.yml

# Use CVE over GHSA prefix.
# 7/7/2026: gems/commonmarker/CVE-2023-37463.yml
rm -rf gems/commonmarker/GHSA-7vh7-fw88-wj87.yml

# Disputed by the WEBrick maintainers. CVEs were assigned without
# maintainer involvement, and WEBrick's documented scope has excluded
# production use since 2020.
# 7/10/2026: https://github.com/ruby/webrick/issues/198
rm -f gems/webrick/CVE-2024-47220.yml # GHSA-6f62-3596-g6w7
rm -f gems/webrick/CVE-2026-38969.yml # GHSA-h4w6-wx8r-p68v

# https://github.com/Shopify/ruby-lsp/security/advisories/GHSA-2x7g-8mp4-572w
# is a Shopify.ruby-lsp (VS Code Extension), not a Ruby gem.

# https://github.com/ckeditor/ckeditor4/security/advisories/GHSA-vh5c-xwqv-cv9g
# is not a Ruby gem, it is a WYSIWYG editor.

# https://github.com/ua-parser/uap-core/security/advisories/GHSA-p4pj-mg4r-x6v4
# is not a Ruby gem, it is a npm (javascript) package.

# https://github.com/github/cmark-gfm/security/advisories/GHSA-7gc6-9qr5-hc85
# https://github.com/github/cmark-gfm/security/advisories/GHSA-cgh3-p57x-9q7q
# are not a Ruby gems, no Ruby code.

# https://github.com/omniauth/omniauth-saml/security/advisories/GHSA-cgp2-2cmh-pf7x
# Dev said, so removed advisory: "The listed vulnerability is an error in
# their documented usage. Updating the gem does not make an app more secure."
rm -f gems/omniauth-saml/GHSA-cgp2-2cmh-pf7x.yml
# https://github.com/joniles/mpxj/security/advisories/GHSA-jf2p-4gqj-849g
# does not involve Ruby code.

# https://github.com/devise-two-factor/devise-two-factor/security/advisories/GHSA-chcr-x7hc-8fp8
# https://github.com/advisories/GHSA-chcr-x7hc-8fp8
# was never patched and withdrawn on 3/19/2026.

# CVE-2024-43368: https://github.com/basecamp/trix/security/advisories/GHSA-qm2q-9f3q-2vcv
# CVE-2025-46812: https://github.com/basecamp/trix/security/advisories/GHSA-mcrw-746g-9q8h
# CVE-2024-53847: https://github.com/basecamp/trix/security/advisories/GHSA-6vx4-v2jw-qwqh
# CVE-2025-21610: https://github.com/basecamp/trix/security/advisories/GHSA-j386-3444-qgwg
# all 4 are NPM related, not Ruby.

######################################################################
# PasswordPusher SUMMARY: Yes, Ruby Fixed, none are gems.
#.....................................................................
# https://github.com/pglombardo/PasswordPusher/security/advisories/GHSA-59w3-h5v2-c4xw
# - https://github.com/pglombardo/PasswordPusher/releases/tag/v2.9.2
#   - https://rubygems.org/gems/pwpush (https://eu.pwpush.com - 2016)
# Release 2.9.2; pglombardo/PasswordPusher; RUBY code; Bash Poc; Ruby fix; No CVE
#...
# https://github.com/pglombardo/PasswordPusher/security/advisories/GHSA-76c2-66pg-fj2f
#  - https://github.com/pglombardo/PasswordPusher/releases/tag/v2.8.1
# Release 2.8.1; pglombardo/PasswordPusher; RUBY code; Bash Poc; Ruby fix; No CVE
#...
# https://github.com/pglombardo/PasswordPusher/security/advisories/GHSA-qfh8-f79c-x86c
# - https://github.com/pglombardo/PasswordPusher/pull/4381
#   - https://github.com/pglombardo/PasswordPusher/releases/tag/v2.4.2
# Release 2:4.2 - Ruby rb code; Unreviewed GHSA
#...
# https://github.com/pglombardo/PasswordPusher/security/advisories/GHSA-4fwj-m62q-pp47
# Never patched; CVE-2024-56733; Password Pusher; No project references
#...
# https://github.com/pglombardo/PasswordPusher/security/advisories/GHSA-ffp2-8p2h-4m5j
# - https://github.com/pglombardo/PasswordPusher/releases/tag/v1.49.0
#   - https://github.com/pglombardo/PasswordPusher/pull/2797
# Release 1.49.0; Password Pusher Application; yml and ruby fixes
#...
# https://github.com/pglombardo/PasswordPusher/security/advisories/GHSA-5chg-cq29-gfqf
# - https://github.com/pglombardo/PasswordPusher/releases/tag/v1.48.1
# Release 1.48.1; Password Pusher Application; erb file code fix

#.....................................................................

# 7/23/2026: GHSA/WITHDRAWN: https://github.com/advisories/GHSA-h385-52j6-9984
rm -f gems/agoo/CVE-2020-7670.yml

# 7/23/2026: GHSA/WITHDRAWN: https://github.com/advisories/GHSA-gmg5-r3c4-3fm9
rm -f gems/fat_free_crm/CVE-2019-10226.yml

# 7/23/2026: GHSA/WITHDRAWN: https://github.com/advisories/GHSA-4249-gjr8-jpq3
rm -f gems/prosemirror_to_html/GHSA-4249-gjr8-jpq3.yml

# 7/23/2026: GHSA/WITHDRAWN: https://github.com/advisories/GHSA-mqcp-p2hv-vw6x
rm -f gems/thor/CVE-2025-54314.yml

# 7/23/2026: GHSA/WITHDRAWN: https://github.com/advisories/GHSA-vc8w-jr9v-vj7f
#  * (REJECTED) https://nvd.nist.gov/vuln/detail/CVE-2024-6531
rm -f gems/bootstrap/CVE-2024-6531.yml

# 7/23/2026: GHSA/WITHDRAWN: https://github.com/advisories/GHSA-7mj4-2984-955f
# * (DISPUTED) https://nvd.nist.gov/vuln/detail/CVE-2018-18307
rm -f gems/alchemy_cms/CVE-2018-18307.yml

# 7/29/2026: Last release of sqlite3-ruby was 1/16/2011.
rm -f gems/sqlite3-ruby/CVE-2026-54619.yml \
      gems/sqlite3-ruby/CVE-2026-54620.yml
# 7/27/2026: GHSL/Not a gem
# https://securitylab.github.com/advisories/GHSL-2024-001_GHSL-2024-003_rubygems_org
# https://github.com/rubygems/rubygems.org/security/advisories/GHSA-4vc5-whwr-7hh2
# https://nvd.nist.gov/vuln/detail/CVE-2024-35221

# 8/15/2026: Using GHSA filenames (new policy) instead of CVE filenames.
rm -f gems/action_text-trix/CVE-2026-73426.yml \
      gems/action_text-trix/CVE-2026-73427.yml \
      gems/action_text-trix/CVE-2026-73428.yml \
      gems/loofah/CVE-2026-73490.yml \
      gems/loofah/CVE-2026-73491.yml \
      gems/rails-html-sanitizer/CVE-2026-73648.yml

# 8/15/2026: Using GHSA filenames (new policy) instead of CVE filenames.
rm -f gems/kobako/CVE-2026-55107.yml

# "chkr" IGNORE-THEM (2022) advisories (8/21/2026: None in this repo)
# #......................................................................
# # Ruby mentioned
# GHSA-5458-w8p3-f624 - CVE-2017-7642 (mentions ruby but not ruby lang)
# GHSA-hwm5-7hrp-v744 - CVE-2006-6979 (mentions ruby, not ruby lang)
# GHSA-2jww-8ppq-f5qp - CVE-2019-12575 (mentions ruby but not ruby lang)
# #......................................................................
# # DISPUTED
# GHSA-c2xw-j3rw-89x2 DISPUTED - SQL injection vul (Rails)
# GHSA-rjh4-8mqr-rvr8 DISPUTED - SQL injection vul (Rails)
# GHSA-vqpc-h5g8-fhrw DISPUTED - SQL injection vul (Rails)
# GHSA-4w6g-25w8-c8vc DISPUTED - SQL injection vul (Rails)
# GHSA-6qq6-x75v-fgg7 DISPUTED - openssl extension - CVE-2014-2734
# GHSA-jwh5-q83f-2jjc DISPUTED - WEBrick gem 1.4.2
# #......................................................................
# #NOT RUBY (Ruby Tools)
# GHSA-6r9x-mqf6-jvrp - CVE-2017-1000047 - rbenv (ruby tool)
# GHSA-9j7m-jqrm-mcj3 - CVE-2019-5624 - Rapid7 Metasploit Framework (tool)
# GHSA-rm8f-p7g6-p8p4 - CVE-2009-4079 - (redmine, not ruby lang)
# GHSA-68hg-cfx6-pvhh - CVE-2009-4078 - (redmine, not ruby lang)
# GHSA-xg2h-5xr2-29jw - CVE-2026-59861 - (Microsoft/Kiota Ruby code generator)
# #......................................................................
# # NOT RUBY
# GHSA-qgq2-pf5j-2fvq JAVASCRIPT/Prototype.js
# GHSA-w8r8-w5w4-4w4v - CVE-2014-0160  - openssl - not directly ruby
#    https://www.ruby-lang.org/en/news/2014/04/10/severe-openssl-vulnerability
# GHSA-h4xp-827w-ffh7 - CVE-2016-4864 (ho2, not mruby lang)
# GHSA-jmhx-fqfh-838h NOT-RUBY
# CVE-2022-45301      NOT-RUBY
# GHSA-6938-wq9x-9rgg - CVE-2012-1241 (ActiveScriptRuby)
# GHSA-6f39-fvhf-c6qr - CVE-2017-11465 (REJECTED) (Ruby)
# GHSA-rc82-v3mm-rhj2 - CVE-2011-3624.yml (REJECTED) (Ruby)
# GHSA-94xx-gq3f-6gw4 - CVE-2026-1097.yml (not ruby)
# #......................................................................
# # Redhat
# GHSA-3fcg-qm7h-hhpw (red hat #3)
# GHSA-gphm-f2cq-m9pv (red hat #2)
# GHSA-w5v4-7h7x-xfvq (red hat #1)
# GHSA-h459-7mrx-8pvc - CVE-2014-0241 (Red hat plugin, not ruby lang)
# GHSA-f29j-vf7h-f9g9 - CVE-2013-1945 (Red hat/Ruby 1.9.3)

# 8/26/2026
# GHSA-9jfq-54vc-9rr2 - CVE-2022-3874 (foreman/Withdrawn)
# GHSA-wv67-q8rr-grjp - CVE-2019-5428 (jquery/jquery-rails/Duplicate)
# GHSA-257q-pv89-v3xv - CVE-2020-23064 (jquery/jquery-rails/Duplicate)

# 8/28/2026
# GHSA-mqcp-p2hv-vw6x - CVE-2025-54314 (thor/Withdrawn)
# GHSA-9jfq-54vc-9rr2 - CVE-2022-3874  (foreman/Withdrawn)
# GHSA-w9fp-2996-hhwx - CVE-2019-16254 (ruby/Disputed)

# 8/31/2026: Newly discovered withdrawns and duplicates.
# ....................................................................
# DUPLICATES:
# spree_auth_devise | https://github.com/advisories/GHSA-gpqc-4pp7-5954 (duplicate)
# spree_auth_devise | https://github.com/advisories/GHSA-8xfw-5q82-3652 (duplicate)
# audited | https://github.com/advisories/GHSA-v444-jggx-6v7f (duplicate)
# camaleon_cms | https://github.com/advisories/GHSA-3hp8-6j24-m5gm (duplicate)
# commonmarker | https://github.com/advisories/GHSA-c2v4-chx5-vff6 (duplicate)
# encoded_id-rails | https://github.com/advisories/GHSA-4553-hq82-8654 (duplicate)
# iodine | https://github.com/advisories/GHSA-qwf7-rv77-fcr3 (duplicate)
# httparty | https://github.com/advisories/GHSA-g47j-3m2m-74qv (duplicate)
# ====================================================================
# WITHDRAWNS:
# nokogiri | https://github.com/advisories/GHSA-jc9r-qcgw-fxq9 (withdrawn)
# nokogiri | https://github.com/advisories/GHSA-pf9w-gvcf-gv7m (withdrawn)
# nokogiri | https://github.com/advisories/GHSA-5mwf-688x-mr7x (withdrawn)
# nokogiri | https://github.com/advisories/GHSA-r3w4-36x6-7r99 (withdrawn)
# nokogiri | https://github.com/advisories/GHSA-vcc3-rw6f-jv97 (withdrawn)
# ....................................................................
# rails-html-sanitizer | https://github.com/advisories/GHSA-77pc-q5q7-qg9h (withdrawn)
# rails-html-sanitizer | https://github.com/advisories/GHSA-mrhj-2g4v-39qx (withdrawn)
# rails-html-sanitizer | https://github.com/advisories/GHSA-qc8j-m8j3-rjq6 (withdrawn)
# ....................................................................
# actionpack | https://github.com/advisories/GHSA-9chr-4fjh-5rgw (withdrawn)
# actionpack | https://github.com/advisories/GHSA-vwfg-qj3r-6v3r (withdrawn)
# actionpack | https://github.com/advisories/GHSA-m53f-rhq8-q6hf (withdrawn)
# actionpack | https://github.com/advisories/GHSA-5xmj-wm96-fmw8 (withdrawn)
# actionpack | https://github.com/advisories/GHSA-23v3-qfrj-wmgh (withdrawn)
# actionpack | https://github.com/advisories/GHSA-qf5x-qgx7-437h (withdrawn)
# actionpack | https://github.com/advisories/GHSA-544j-77x9-h938 (withdrawn)
# actionpack | https://github.com/advisories/GHSA-hx46-vwmx-wx95 (withdrawn)
# actionview | https://github.com/advisories/GHSA-6834-r92f-jj42 (withdrawn)
# actionview | https://github.com/advisories/GHSA-2pwf-xwr3-hp55 (withdrawn)
# activemodel | https://github.com/advisories/GHSA-v543-gqhh-6gww (withdrawn)
# activerecord | https://github.com/advisories/GHSA-7phj-gmgx-2r66 (withdrawn)
# activerecord | https://github.com/advisories/GHSA-hm48-76wh-q86v (withdrawn)
# activerecord | https://github.com/advisories/GHSA-m8h6-m9p5-p2f8 (withdrawn)
# activesupport | https://github.com/advisories/GHSA-35c4-f3rq-f9g3 (withdrawn)
# ....................................................................
# archive-tar-minitar | https://github.com/advisories/GHSA-cwp3-834g-x79g (withdrawn)
# bootstrap | https://github.com/advisories/GHSA-9mvj-f7w8-pvh2 (withdrawn)
# colorscore | https://github.com/advisories/GHSA-9wcm-rrvh-qjc8 (withdrawn)
# devise_invitable | https://github.com/advisories/GHSA-wj5j-xpcj-45gc (withdrawn)
# doorkeeper | https://github.com/advisories/GHSA-5p9f-55j8-922m (withdrawn)
# espeak-ruby | https://github.com/advisories/GHSA-w655-w578-99pq (withdrawn)
# festivaltts4r | https://github.com/advisories/GHSA-9wv8-jgw4-4g28 (withdrawn)
# govuk_tech_docs | https://github.com/advisories/GHSA-4mvm-xh8j-fv27 (withdrawn)
# jquery-ui-rails | https://github.com/advisories/GHSA-g8q2-24jh-5hpc (withdrawn)
# metasploit-framework | https://github.com/advisories/GHSA-6pm2-j2v8-h3cj (withdrawn)
# minitar | https://github.com/advisories/GHSA-cwp3-834g-x79g (withdrawn)
# prosemirror_to_html | https://github.com/advisories/GHSA-vfpf-xmwh-8m65 (withdrawn)
# rack | https://github.com/advisories/GHSA-9vc2-p34x-jhxh (withdrawn)
# rack-mini-profiler | https://github.com/advisories/GHSA-995j-587r-259w (withdrawn)
# resque-scheduler | https://github.com/advisories/GHSA-q7jc-v6f2-q9jr (withdrawn)
# rubyzip | https://github.com/advisories/GHSA-3q5q-f79q-7hr2 (withdrawn)
# safemode | https://github.com/advisories/GHSA-44vc-fpcg-5cc5 (withdrawn)
# safemode | https://github.com/advisories/GHSA-8474-rc7c-wrhp (withdrawn)
# spree_auth_devise | https://github.com/advisories/GHSA-6mqr-q86q-6gwr (withdrawn)
# web-console | https://github.com/advisories/GHSA-82x2-g7vr-39wq (withdrawn)

# 9/4/2026: Use GHSA prefix over CVE.
rm -f gems/mail/CVE-2026-63435.yml
rm -f gems/nokogiri/CVE-2026-79770.yml
rm -f gems/nokogiri/CVE-2026-79771.yml
rm -f gems/nokogiri/CVE-2026-79772.yml

# 9/4/2026: More duplicates and withdrawns
# nokogiri  | https://github.com/advisories/GHSA-5jhf-fpp7-v2pv (duplicate)
# nokogiri  | https://github.com/advisories/GHSA-xqqh-3w52-q8p7 (duplicate)
# nokogiri  | https://github.com/advisories/GHSA-rh9x-7xjc-vwx2 (duplicate)
# paperclip | https://github.com/advisories/GHSA-phmw-pv3f-vvx7 (withdrawn)
# sprockets | https://github.com/advisories/GHSA-r4x3-g983-9g48 (withdrawn)

# 9/9/2026: 
# Rubygmems | https://github.com/advisories/GHSA-mq4m-44x6-6r2v (not a gem)

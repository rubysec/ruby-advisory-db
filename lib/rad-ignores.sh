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
rm -f gems/webrick/CVE-2024-47220.yml
rm -f gems/webrick/CVE-2026-38969.yml

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

exit

# AL>> QUESTION (ruby or jruby)?
# 5/25/2026: Using gems/nokogiri/CVE-2022-24839.yml (On JRuby)
# https://github.com/advisories/GHSA-gx8x-g87m-h5q6 (on JRuby)
#rm -f gems/nokogiri/GHSA-gx8x-g87m-h5q6.yml

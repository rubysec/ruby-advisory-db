#!/usr/bin/env bash

# USAGE: Either 
#    "syncnot.sh"   (default: yes, create new branch)
#    "syncbot.sh ." (skip creating new branch)

function syncit() {
    echo "SYNCIT ########################################################"
    git fetch parent
    git checkout master
    git merge parent/master
    git push
}

function autogitb() {
    if [ "X$1X" == "XX" ] ; then
        echo "AUTOGITB ##################################################"
        git checkout -b "ghsa-syncbot-$(date '+20%y-%m-%d')-$(date '+%T' |sed -e 's,:,_,g')"
    else
        echo "NO *** AUTOGITB.SH ########################################"
    fi
}

syncit

autogitb "$1"

# 7/21/2023: Use official version now.
#GHITSCRIPT=$HOME/bin/github_advisory_sync.rb
#sed -e "s,\['FIX ME'\],vulnerabilities," ${GHITSCRIPT} \
#  > $HOME/Projects/ruby-advisory-db/lib/github_advisory_sync.rb

git diff

rm -f Gemfile.lock
bundle

GH_API_TOKEN=${GH_TOK} bundle exec rake sync_github_advisories

if [ "X$1X" == "XrawX" ] ; then
    echo "No post-processing.sh and ignore-dup-advs.sh runs"
else
    scripts/post-processing.sh
    scripts/ignore-dup-advs.sh
fi

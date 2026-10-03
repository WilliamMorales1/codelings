#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# names: map(.name)   (or [.[].name])
# stars: (map(.stargazers_count) | add)   -- the parentheses matter.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- repos.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/repos.json"

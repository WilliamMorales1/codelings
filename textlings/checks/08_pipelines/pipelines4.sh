#!/usr/bin/env bash
# REQUIRES: jq gawk sort head
# HINT
# In jq: select(.archived | not) and .language // "none".
# In awk: count repos too (n[$1]++) and print stars[l], n[l], l.
# Then sort -k1,1nr | head -3.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out sh expected.txt -- repos.json
expect_out --label "same program on a second, hidden input" sh "$FIX/expected.txt" -- "$FIX/repos.json"

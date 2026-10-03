#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# Gluing fields with commas breaks as soon as a title contains a comma or
# a quote. Build arrays and let @csv do the quoting:
# ["number", ...], (.[] | [.number, .title, .user.login, .state, .comments]) | @csv
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- issues.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/issues.json"

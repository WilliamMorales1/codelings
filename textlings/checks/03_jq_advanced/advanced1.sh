#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# After group_by, each element is an *array* of issues, so the login is
# .[0].user.login. For the order: sort_by(-.issues, .author)
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- issues.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/issues.json"

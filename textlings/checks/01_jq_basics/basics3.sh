#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# `.[].number, .[].head.ref` walks the array twice: first all numbers,
# then all branches. Iterate once and pipe each PR into both fields:
# .[] | .number, .head.ref
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- pulls.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/pulls.json"

#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# Arrays count from 0, and an array has no .count field (you get null).
# length counts it, and .[-1] is the last element whatever the size.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- releases.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/releases.json"

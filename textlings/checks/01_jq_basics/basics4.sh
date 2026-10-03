#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# The filter is fine; only the output format is wrong. Add -c to the flags
# file.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- pod.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/pod.json"

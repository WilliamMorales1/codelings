#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# Add -s to the flags so . is an array of all entries, then wrap the
# first expression: limit(3; .[] | select(...) | ...)
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- journal.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/journal.json"
must_use filter.jq "limit|first" "limit or first"

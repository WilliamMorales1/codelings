#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# map on an object returns an array of its values: the names are gone.
# with_entries(.value |= sub("^[\\^~]"; "")) edits each value in place.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- package.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/package.json"

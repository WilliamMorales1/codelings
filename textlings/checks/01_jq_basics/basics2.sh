#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# .items is an array, and an array has no .metadata, hence "Cannot index
# array with metadata". Iterate it first: .items[].metadata.name
# Then put -r into the flags file so the quotes go away.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- pods.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/pods.json"

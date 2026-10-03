#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# With -r a null prints as the word null. Add a default:
# .metadata.labels.app // "(none)"
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- pods.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/pods.json"

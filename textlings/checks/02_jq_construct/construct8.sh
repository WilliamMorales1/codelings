#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# The values are still base64. Decode, then quote for the shell:
# \(.value | @base64d | @sh)
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- secret.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/secret.json"

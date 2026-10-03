#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# The broken version yields an array of one-key objects. Either merge them
# with `add`, or skip the map and use from_entries directly: it accepts
# {"name": .., "value": ..} entries as they are.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- deployment.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/deployment.json"

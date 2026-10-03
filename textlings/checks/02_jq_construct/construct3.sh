#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# `.status.phase = "Running"` does not compare anything: it sets the
# field and returns the whole (truthy) object, so every prod pod passes.
# You want .status.phase != "Running".
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- pods.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/pods.json"

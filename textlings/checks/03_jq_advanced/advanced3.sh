#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# Start from {} and add each pod's restarts under its node's key:
# reduce .items[] as $p ({}; .[$p.spec.nodeName] += ($p.status.containerStatuses | map(.restartCount) | add))
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- pods.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/pods.json"
must_use filter.jq "reduce" "reduce"

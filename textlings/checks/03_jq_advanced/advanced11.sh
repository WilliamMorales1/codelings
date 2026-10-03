#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# Replace the literals with $ns, $min and $ENV.CLUSTER. `x as $r` names a
# value so you can use it twice.
source "$TEXTLINGS_ROOT/checks/lib.sh"

CLUSTER=prod-eu expect_out jq expected.txt -- --arg ns shop --argjson min 3 pods.json
CLUSTER=lab-1 expect_out --label "hidden input, CLUSTER=lab-1 --arg ns monitoring --argjson min 1" \
  jq "$FIX/expected.txt" -- --arg ns monitoring --argjson min 1 "$FIX/pods.json"

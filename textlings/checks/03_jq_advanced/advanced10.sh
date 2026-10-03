#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# `.spec.replicas * 2` is just a number: the rest of the pipeline then
# runs on that number. Use `.spec.replicas *= 2`. And containers[0] only
# touches the first container; containers[] touches all of them.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- deployment.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/deployment.json"

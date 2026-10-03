#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# Four `.items[]` inside one object is a cartesian product: every name
# combined with every namespace, every node and every phase. Iterate once,
# outside: .items[] | {name: .metadata.name, ...}
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- pods.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/pods.json"

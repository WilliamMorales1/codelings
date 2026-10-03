#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# foreach .[] as $d (0; . + $d.usd; "\($d.date) \($d.usd) \((. * 100 | round) / 100)")
# In the third part, . is the running total and $d is still in scope.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- costs.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/costs.json"
must_use filter.jq "foreach" "foreach"

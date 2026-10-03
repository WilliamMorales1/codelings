#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# Put -n in the flags file and replace the leading `.` with `inputs`:
# reduce (inputs | select(...)) as $e ({}; ...)
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- journal.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/journal.json"
must_use filter.jq "inputs" "inputs"

#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# `.field` selects a field of the input object. expected.txt holds the
# package's name.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- package.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/package.json"

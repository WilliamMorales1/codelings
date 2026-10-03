#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# keys gives the names only, and sorted. to_entries[] keeps file order and
# gives you .key and .value:
# .dependencies | to_entries[] | "\(.key)@\(.value)"
# Then do the same for .devDependencies, joined with a comma.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- package.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/package.json"

#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# group_by(.name) gives one array per package. Collect its versions with
# map(.version) | unique, keep the ones where that has length > 1, then
# join(", "). Two copies of the *same* version do not count.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- package-lock.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/package-lock.json"

#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# with_entries only looks at the top level. Wrap it in walk and only apply
# it to objects:
# walk(if type == "object" then with_entries(select(.value != null)) else . end)
# (del(.. | nulls) also works here, but it drops nulls inside arrays too.)
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- repo.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/issue.json"

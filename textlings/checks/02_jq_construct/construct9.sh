#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# The broken version flattens login and ref to the top level. Either
# .[] | pick(.number, .draft, .user.login, .head.ref)
# or build {user: {login: ..}, head: {ref: ..}} yourself.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- pulls.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/pulls.json"

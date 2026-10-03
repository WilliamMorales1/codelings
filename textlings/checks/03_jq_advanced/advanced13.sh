#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# Save the raw line first (. as $line), because inside catch . is the
# error message. Define
# def entry: fromjson | if has("level") then . else error("no level") end;
# then try (entry | ...) catch (if . == "no level" then ... else ... end)
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- app.log
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/app.log"
must_use filter.jq "error\\(" "error(...)"

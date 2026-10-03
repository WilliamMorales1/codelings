#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# A WatchEvent has no payload.commits, so .payload.commits is null and
# `null | .[]` is an error that kills the run. Make the iteration optional:
# .payload.commits[]?
# (select(.type == "PushEvent") would work too; you meet select in chapter 02.)
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- events.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/events.json"

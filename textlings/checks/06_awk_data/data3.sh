#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# Field 4 is a whole member list; split it and loop:
# n = split($4, members, ","); for (i = 1; i <= n; i++) ...
# Only put a comma in front when the user already has a group: (u in groups).
# Groups with no members give n = 0, so they add nothing.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out --sort awk expected.txt -- group
expect_out --sort --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/group"

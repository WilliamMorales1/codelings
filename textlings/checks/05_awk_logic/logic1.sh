#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# Two bugs in one: "500" in quotes makes it a string comparison, and >
# leaves out 500 itself. Use a number: $9 >= 500
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- access.log
expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/access.log"

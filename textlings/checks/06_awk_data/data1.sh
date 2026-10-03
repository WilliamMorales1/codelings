#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# n[$9] = 1 marks the status as seen; it does not count. n[$9]++
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out --sort awk expected.txt -- access.log
expect_out --sort --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/access.log"

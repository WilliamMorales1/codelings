#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# NR counts the header line too: count the processes yourself in a
# `NR > 1 { n++; ... }` block. For one decimal use printf "%.1f".
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- ps.txt
expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/ps.txt"

#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# `print $2 $11` glues the two fields together. Separate them with a comma:
# print $2, $11
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- ps.txt
expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/ps.txt"

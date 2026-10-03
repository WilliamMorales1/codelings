#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# $NF-1 means ($NF) - 1: the mount point turned into a number, minus one.
# The field before the last one is $(NF-1). And the header should go:
# NR > 1 { ... }
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- df.txt
expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/df.txt"

#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# BEGIN { printf "%-28s %4s %7s\n", "MOUNT", "USE", "FREE" }
# NR > 1 { printf "%-28s %4s %7.1f GiB\n", $NF, $5, $4 / 1048576 }
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- df.txt
expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/df.txt"

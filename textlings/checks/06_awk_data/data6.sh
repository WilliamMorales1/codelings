#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# print prints $0 untouched. Assign a field first so awk rebuilds it with
# OFS: { $1 = $1; print }
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- ps.txt
expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/ps.txt"

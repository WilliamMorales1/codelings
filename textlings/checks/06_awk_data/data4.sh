#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# first = substr($2, 1, index($2, " ") - 1)
# email = tolower($3)
# sub only removes the first non-digit; gsub removes them all.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- users.csv
expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/users.csv"

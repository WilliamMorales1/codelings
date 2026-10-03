#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# There are no blanks in most passwd lines, so $1 is the whole line and $7
# is empty. Split on colons: BEGIN { FS = ":" }
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- passwd
expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/passwd"

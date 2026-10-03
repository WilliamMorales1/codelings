#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# The edited line comes out with spaces between fields: set OFS = ":"
# too (BEGIN { FS = OFS = ":" }). And use the variable, not a literal:
# $1 == user
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- -v user=deploy passwd
expect_out --label "hidden input, -v user=bob" awk "$FIX/expected.txt" -- -v user=bob "$FIX/passwd"

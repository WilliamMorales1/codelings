#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# Loop while n >= 1024, dividing and counting steps in a local variable
# (declared as an extra parameter). The count indexes "KMGT" with substr.
# sprintf("%.1f%s", n, unit) builds the result.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- du.txt
expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/du.txt"
must_use prog.awk "function human" "a function human"

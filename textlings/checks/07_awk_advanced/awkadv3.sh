#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# Set FS = "\n" too, then loop over the fields: the key is the text
# before the first colon (trailing blanks removed), the value is what is
# after the first ": ". Store them in an array (clear it for each
# package) and print when f["Install Reason"] == "Explicitly installed".
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- pacman-Qi.txt
expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/pacman-Qi.txt"
must_use prog.awk "RS *= *\"\"" "RS = \"\""

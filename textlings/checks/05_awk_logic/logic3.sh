#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# use = $5 keeps the string "9%", and "9%" >= 75 compares text: "9" sorts
# after "7", so a nearly empty disk is WARN and a full one (100%) is ok.
# Make it a number: use = $5 + 0
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- df.txt
expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/df.txt"

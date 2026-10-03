#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# The file is comma separated but FS is still blanks: set FS = "," in
# BEGIN. Then printf "%s %.2f\n", s, sum[s]
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out --sort awk expected.txt -- costs.csv
expect_out --sort --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/costs.csv"

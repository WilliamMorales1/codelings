#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# Run it in a terminal: TOTAL comes out on top, because sort only prints
# once its input is closed, which by default happens when awk exits. Put
# the command in a variable, and close(that_variable) after the loop,
# before TOTAL.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- ci.csv
expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/ci.csv"
must_use prog.awk "close\\(" "close()"

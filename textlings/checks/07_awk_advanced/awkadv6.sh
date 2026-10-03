#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# Set PROCINFO["sorted_in"] = "@val_num_desc" before the for loop in END.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out gawk expected.txt -- access.log
expect_out --label "same program on a second, hidden input" gawk "$FIX/expected.txt" -- "$FIX/access.log"
must_use prog.awk "sorted_in|asort" "PROCINFO[\"sorted_in\"] or asort"

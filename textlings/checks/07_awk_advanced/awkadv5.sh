#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# BEGIN { FPAT = "([^,]*)|(\"[^\"]*\")" }
# Then strip quotes with gsub(/"/, "", name), and test company == "".
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out gawk expected.txt -- contacts.csv
expect_out --label "same program on a second, hidden input" gawk "$FIX/expected.txt" -- "$FIX/contacts.csv"
must_use prog.awk "FPAT" "FPAT"

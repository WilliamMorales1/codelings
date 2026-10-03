#!/usr/bin/env bash
# REQUIRES: jq gawk sort uniq head
# HINT
# Four fixes: sort before uniq -c; sort the counts numerically, largest
# first, then by IP: sort -k1,1nr -k2,2; and uniq -c pads the count with
# spaces, so reprint it: awk '{ print $1, $2 }'.
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out sh expected.txt -- access.log
expect_out --label "same program on a second, hidden input" sh "$FIX/expected.txt" -- "$FIX/access.log"

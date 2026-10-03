#!/usr/bin/env bash
# REQUIRES: jq
# HINT
# Divide by 1024 until the number is below 1024, counting the steps; the
# count picks the unit. `until(cond; update)` loops, or write a recursive
# def. Truncate to one decimal with  . * 10 | floor / 10 .
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out jq expected.txt -- lsblk.json
expect_out --label "same program on a second, hidden input" jq "$FIX/expected.txt" -- "$FIX/lsblk.json"

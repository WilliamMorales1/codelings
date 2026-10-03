#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# Without `next`, the customer lines fall through to the other rules and
# get printed as orders. Then test membership: if ($2 in name) ... else ...
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- customers.csv orders.csv
expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/customers.csv" "$FIX/orders.csv"

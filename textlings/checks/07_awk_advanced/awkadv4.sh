#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# getline returns -1 when the file cannot be opened, and -1 is true, so
# the loop never ends. while ((getline line < hosts) > 0)
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- -v hosts=hosts.txt access.log
expect_out --label "hidden input, hosts file missing" awk "$FIX/expected.txt" -- -v hosts=/nonexistent/hosts.txt "$FIX/access.log"

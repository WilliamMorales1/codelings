#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# Capture day, month, year and hour, then reorder them:
# gensub(/^\[([0-9]+)\/([A-Za-z]+)\/([0-9]+):([0-9]+):.*/, "\\3-\\2-\\1 \\4h", 1, $4)
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out gawk expected.txt -- access.log
expect_out --label "same program on a second, hidden input" gawk "$FIX/expected.txt" -- "$FIX/access.log"
must_use prog.awk "gensub" "gensub"

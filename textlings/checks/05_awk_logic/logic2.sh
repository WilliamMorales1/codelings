#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# nobody has uid 65534, so cap the range. And match the shell by its last
# path component instead of one exact path: $7 !~ /\/(nologin|false)$/
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- passwd
expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/passwd"

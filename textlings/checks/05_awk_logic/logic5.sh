#!/usr/bin/env bash
# REQUIRES: gawk
# HINT
# /^#/ misses comments with blanks in front, and blank lines slip through
# as "=". Skip both: /^[ \t]*#/ || NF == 0 { next }
source "$TEXTLINGS_ROOT/checks/lib.sh"

expect_out awk expected.txt -- sshd_config
expect_out --label "same program on a second, hidden input" awk "$FIX/expected.txt" -- "$FIX/sshd_config"

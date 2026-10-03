#!/bin/sh
# Counts its runs in state/count.
f="$(dirname "$0")/state/count"
n=$(cat "$f" 2>/dev/null || echo 0)
echo $((n + 1)) >"$f" && echo "run number $((n + 1))"

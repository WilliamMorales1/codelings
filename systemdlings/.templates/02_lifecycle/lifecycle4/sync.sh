#!/bin/sh
# Pretend sync tool. Exit codes: 0 synced, 3 nothing to do, anything else is an error.
code=$(cat "$(dirname "$0")/exit-code" 2>/dev/null || echo 3)
case $code in
0) echo "synced 12 files" ;;
3) echo "already up to date, nothing to sync" ;;
*) echo "sync failed with code $code" >&2 ;;
esac
exit "$code"

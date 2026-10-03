#!/bin/sh
# Pretend client that cannot reach its database for the first two attempts.
state="$(dirname "$0")/attempts"
n=$(cat "$state" 2>/dev/null || echo 0)
n=$((n + 1))
echo "$n" >"$state"
if [ "$n" -lt 3 ]; then
    echo "attempt $n: database not reachable yet" >&2
    exit 1
fi
echo "attempt $n: connected"
exec sleep infinity

#!/usr/bin/env bash
# info1 — reading INFO from a script

REDIS_CLI=${REDIS_CLI:-redis-cli -p 6390}

field() { tr -d '\r' | awk -F: -v f="$1" '$1 == f { print $2 }'; }

echo "used_memory=$($REDIS_CLI INFO memory | field used_memory)"
echo "clients=$($REDIS_CLI INFO clients | field connected_clients)"

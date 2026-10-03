#!/usr/bin/env bash
# expiry5 — the cache-aside pattern

REDIS_CLI=${REDIS_CLI:-redis-cli -p 6390}
city=$1
key="cache:weather:$city"

cached=$($REDIS_CLI GET "$key")
if [[ -n "$cached" ]]; then
  echo "$cached"
  exit 0
fi

report=$(./slow_api.sh "$city")
$REDIS_CLI SET "$key" "$report" EX 300 >/dev/null
echo "$report"

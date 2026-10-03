#!/usr/bin/env bash
# expiry5 — the cache-aside pattern
#
# Learn: cache-aside means the app asks the cache first, and only on a miss
# calls the slow source and stores the answer WITH a TTL, so stale data
# ages out by itself. With redis-cli in a script, a missing key prints an
# empty line.
#
# Task: make `./fetch.sh CITY` print the forecast for CITY, calling
# ./slow_api.sh only when cache:weather:CITY is not cached. Cache answers
# for 300 seconds. Right now every call hits the API and entries never
# expire.
#
# Try it: redislings server (other terminal), then ./fetch.sh paris twice.
#

REDIS_CLI=${REDIS_CLI:-redis-cli -p 6390}
city=$1
key="cache:weather:$city"

# TODO: return the cached value if there is one.

report=$(./slow_api.sh "$city")
$REDIS_CLI SET "$key" "$report" >/dev/null
echo "$report"

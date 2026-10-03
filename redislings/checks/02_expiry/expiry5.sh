#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# cached=$($REDIS_CLI GET "$key")
# if [[ -n "$cached" ]]; then echo "$cached"; exit 0; fi
# ...and add EX 300 to the SET.
source "$REDISLINGS_ROOT/checks/lib.sh"

need_file fetch.sh slow_api.sh
start_redis
export_cli
export API_LOG="$RDIR/api.log"
: >"$API_LOG"
for city in paris paris berlin paris; do
  got=$(bash ./fetch.sh "$city" 2>&1) || fail "fetch.sh $city exited non-zero: $got"
  expect_eq "$got" "forecast for $city: sunny, 21C" "fetch.sh $city prints the forecast"
done
expect_eq "$(sort "$API_LOG" | uniq -c | awk '{print $2 "=" $1}' | paste -sd' ')" "berlin=1 paris=1" "the API is called once per city"
expect_between "$(r TTL cache:weather:paris)" 290 300 "cached entries expire after 300s"
r PEXPIRE cache:weather:paris 1 >/dev/null
sleep 0.05
bash ./fetch.sh paris >/dev/null
expect_eq "$(grep -c paris "$API_LOG")" "2" "after the entry expires, the API is called again"

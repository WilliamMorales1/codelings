#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# XREVRANGE events + - COUNT 2    (end first: + then -)
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
forbid commands.redis '^ECHO' "no ECHO: read the stream"
for n in 5 3; do
  flush
  for i in $(seq "$n"); do echo "XADD events 1700000000000-$i n $i"; done | seed
  run_file commands.redis
  ids=$(grep -o -E '1700000000000-[0-9]+' <<<"$OUT" | paste -sd' ')
  expect_eq "$ids" "1700000000000-$n 1700000000000-$((n - 1))" "the 2 newest of $n entries, newest first"
done

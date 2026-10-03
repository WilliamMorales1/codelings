#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# INCR key adds 1; INCRBY key N adds N. Both return the new value, so you
# never need the GET. Drop the SETs entirely.
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
forbid commands.redis '^SET ' "don't SET the counter: another client may have changed it in between"
for start in 10 250; do
  flush
  seed <<<"SET page:home:views $start"
  run_file commands.redis
  expect_eq "$(r GET page:home:views)" "$((start + 6))" "starting from $start views"
done

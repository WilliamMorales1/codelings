#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# ZINCRBY lb:weekly 50 ada
# ZADD lb:weekly GT 85 bob     (GT: only update when 85 > current score)
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
for v in "120 90" "10 80"; do
  read -r ada bob <<<"$v"
  flush
  seed <<<"ZADD lb:weekly $ada ada $bob bob 55 dee"
  run_file commands.redis
  expect_eq "$(r ZSCORE lb:weekly ada)" "$((ada + 50))" "ada: $ada + 50"
  expect_eq "$(r ZSCORE lb:weekly bob)" "$((bob > 85 ? bob : 85))" "bob keeps his best of $bob and 85"
  expect_eq "$(r ZSCORE lb:weekly cy)" "30" "cy starts at 30"
  expect_eq "$(r ZSCORE lb:weekly dee)" "55" "dee untouched"
done

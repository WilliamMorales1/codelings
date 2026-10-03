#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# GETEX session:9f2c EX 1800
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
expect_eq "$(strip_comments commands.redis | wc -l)" "1" "exactly one command"
for user in user:7 user:42; do
  flush
  seed <<<"SET session:9f2c $user EX 20"
  run_file commands.redis
  expect_eq "$OUT" "\"$user\"" "prints the session value"
  expect_between "$(r TTL session:9f2c)" 1790 1800 "reading the session slid its TTL to 30 minutes"
done

#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# EXPIRE on a key that doesn't exist yet does nothing (reply 0), and the
# SET afterwards creates the key without a TTL. Use one command:
#   SET cache:weather:paris "sunny, 21C" EX 60
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
run_file commands.redis
expect_eq "$(r GET cache:weather:paris)" "sunny, 21C" "cached value"
expect_between "$(r TTL cache:weather:paris)" 55 60 "TTL of cache:weather:paris"
flush
seed <<<"SET cache:weather:paris stale EX 5"
run_file commands.redis
expect_between "$(r TTL cache:weather:paris)" 55 60 "TTL is 60s even when an older entry existed"

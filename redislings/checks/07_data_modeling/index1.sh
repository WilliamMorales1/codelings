#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# Every HSET that changes a city needs a matching index update:
#   SADD idx:user:city:paris 4
#   SMOVE idx:user:city:paris idx:user:city:lyon 2
# Keep them between MULTI and EXEC.
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
seed <<'SEED'
HSET user:1 name Ann city paris
HSET user:2 name Bo city paris
HSET user:3 name Cy city lyon
SADD idx:user:city:paris 1 2
SADD idx:user:city:lyon 3
SEED
run_file commands.redis
require commands.redis '^MULTI' "keep the MULTI/EXEC"
expect_eq "$(r HGET user:4 city)" "paris" "user:4 exists"
expect_eq "$(r HGET user:2 city)" "lyon" "user:2 lives in lyon"
expect_eq "$(r SMEMBERS idx:user:city:paris | sort | paste -sd' ')" "1 4" "paris index: 1 4"
expect_eq "$(r SMEMBERS idx:user:city:lyon | sort | paste -sd' ')" "2 3" "lyon index: 2 3"
expect_eq "$(members "$OUT" | paste -sd' ')" "1 4" "printed the paris index"

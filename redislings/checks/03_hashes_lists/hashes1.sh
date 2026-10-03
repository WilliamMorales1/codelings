#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# HSET takes any number of field/value pairs:
#   HSET user:7 name "Grace Hopper" email grace@navy.mil visits 0
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
run_file commands.redis
expect_eq "$(r TYPE user:7)" "hash" "user:7 is a hash"
expect_eq "$(r HGET user:7 name)" "Grace Hopper" "name field"
expect_eq "$(r HGET user:7 email)" "grace@navy.mil" "email field"
expect_eq "$(r HGET user:7 visits)" "0" "visits field"
expect_eq "$(r HLEN user:7)" "3" "exactly three fields"

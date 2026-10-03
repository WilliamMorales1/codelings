#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# EXPIRE takes seconds, not minutes: 30 minutes is 30 * 60 seconds.
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
seed <<<"SET session:9f2c user:7"
run_file commands.redis
expect_between "$(r TTL session:9f2c)" 1790 1800 "TTL of session:9f2c is about 30 minutes"
expect_eq "$(r GET session:9f2c)" "user:7" "the session value is untouched"

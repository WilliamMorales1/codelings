#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# Change the value in the SET line to "hello, redis" and save.
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
run_file commands.redis
expect_eq "$(r GET greeting)" "hello, redis" "greeting is set"

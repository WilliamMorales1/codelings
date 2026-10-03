#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# RPUSH appends to the tail, so RPUSH pipeline:app build test deploy keeps
# the order you wrote.
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
run_file commands.redis
expect_eq "$(r LRANGE pipeline:app 0 -1)" $'build\ntest\ndeploy' "LRANGE pipeline:app 0 -1"

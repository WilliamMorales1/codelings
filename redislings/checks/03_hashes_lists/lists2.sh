#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# Indexes 0..5 are six elements. The 5 newest are LTRIM recent:user:7 0 4.
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
seed <<<"RPUSH recent:user:7 e5 e4 e3 e2 e1"
run_file commands.redis
expect_eq "$(r LRANGE recent:user:7 0 -1)" $'login\ne5\ne4\ne3\ne2' "5 newest entries, newest first"
flush
seed <<<"RPUSH recent:user:7 e2 e1"
run_file commands.redis
expect_eq "$(r LRANGE recent:user:7 0 -1)" $'login\ne2\ne1' "short lists are not padded or trimmed"

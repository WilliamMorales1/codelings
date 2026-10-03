#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# SADD article:1:tags redis cache redis nosql cache
# SISMEMBER article:1:tags redis     -> (integer) 1
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
run_file commands.redis
expect_eq "$(r TYPE article:1:tags)" "set" "article:1:tags is a set"
expect_eq "$(r SMEMBERS article:1:tags | sort)" $'cache\nnosql\nredis' "each tag once"
expect_eq "$(tail -n 1 <<<"$OUT")" "(integer) 1" "last command asks SISMEMBER ... redis"

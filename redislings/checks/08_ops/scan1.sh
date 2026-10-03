#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# $REDIS_CLI --scan --pattern 'session:*' | wc -l
# (--count 1000 makes each SCAN step bigger and the loop faster.)
source "$REDISLINGS_ROOT/checks/lib.sh"

need_file count_sessions.sh
start_redis
seed <<'SEED'
EVAL "for i = 1, 5000 do redis.call('SET', 'session:' .. i, 'x') end for i = 1, 3000 do redis.call('SET', 'user:' .. i, 'x') end" 0
SEED
r ACL SETUSER default -keys >/dev/null
export_cli
got=$(bash ./count_sessions.sh 2>&1)
expect_eq "$got" "5000" "5000 session keys (KEYS is blocked on this server)"

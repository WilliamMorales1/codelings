#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# Feed the names from --scan into UNLINK, a few hundred per call:
#   $REDIS_CLI --scan --pattern 'session:*' | xargs -r -d '\n' -n 500 $REDIS_CLI UNLINK
source "$REDISLINGS_ROOT/checks/lib.sh"

need_file delete_sessions.sh
start_redis
seed <<'SEED'
EVAL "for i = 1, 3000 do redis.call('SET', 'session:' .. i, 'x') end for i = 1, 1000 do redis.call('SET', 'user:' .. i, 'x') end" 0
SET "session:with space" x
SET sessions:total 3001
SEED
export_cli
bash ./delete_sessions.sh >/dev/null 2>&1
expect_eq "$(r --scan --pattern 'session:*' | wc -l)" "0" "no session:* keys left"
expect_eq "$(r DBSIZE)" "1001" "the 1000 user keys and sessions:total survive"

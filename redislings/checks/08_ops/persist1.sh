#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# Snapshots (save 60 1 and friends) lose everything since the last one.
# Turn on the append-only file and sync it once a second:
#   appendonly yes
#   appendfsync everysec
source "$REDISLINGS_ROOT/checks/lib.sh"

need_file persist.conf
start_redis_raw "$PWD/persist.conf"
expect_match "$(r CONFIG GET appendfsync | tail -n 1)" '^(everysec|always)$' "appendfsync syncs at least once a second"
for i in $(seq 100); do echo "RPUSH queue:jobs job:$i"; done | seed
sleep 1.5
stop_redis
start_redis_raw "$PWD/persist.conf"
expect_eq "$(r LLEN queue:jobs)" "100" "all 100 jobs survived kill -9 and a restart"

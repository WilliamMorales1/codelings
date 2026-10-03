#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# Drop the ~ for exact trimming: XADD metrics:host1 MAXLEN 3 * cpu 42
# (XTRIM metrics:host1 MAXLEN 3 trims without adding.)
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
for i in $(seq 10); do echo "XADD metrics:host1 1700000000000-$i cpu $i"; done | seed
run_file commands.redis
expect_eq "$(r XLEN metrics:host1)" "3" "exactly 3 entries left"
expect_eq "$(r XREVRANGE metrics:host1 + - COUNT 1 | tail -n 1)" "42" "the newest is cpu=42"

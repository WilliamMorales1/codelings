#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# volatile-lru only evicts keys that have a TTL. With no TTLs anywhere,
# nothing is evictable and writes fail with OOM. Use allkeys-lru.
source "$REDISLINGS_ROOT/checks/lib.sh"

need_file cache.conf
start_redis "$PWD/cache.conf"
expect_eq "$(r CONFIG GET maxmemory | tail -n 1)" "4194304" "maxmemory is 4mb"
val=$(head -c 5000 /dev/zero | tr '\0' x)
out=$(for i in $(seq 1400); do echo "SET cache:$i $val"; done | "$REDIS_CLI_BIN" -p "$PORT" 2>&1 | grep -v '^OK$' | sort | uniq -c | head -3)
expect_eq "$out" "" "all 1400 writes of 5 KB succeed"
expect_between "$(r INFO stats | tr -d '\r' | awk -F: '$1 == "evicted_keys" { print $2 }')" 1 100000 "keys were evicted"
expect_eq "$(r EXISTS cache:1400)" "1" "the newest key is still cached"

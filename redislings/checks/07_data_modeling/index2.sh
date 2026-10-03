#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# Without BYSCORE, 18 and 30 are positions (ranks), not ages.
#   ZRANGE idx:user:age 18 30 BYSCORE LIMIT 0 2
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
forbid commands.redis '^ECHO' "no ECHO: query the index"
seed <<<"ZADD idx:user:age 17 1 18 2 25 3 22 4 30 5 31 6 40 7"
run_file commands.redis
expect_eq "$OUT" $'1) "2"\n2) "4"' "the 2 youngest aged 18..30: users 2 and 4"
flush
seed <<<"ZADD idx:user:age 29 8 30 9 12 10"
run_file commands.redis
expect_eq "$OUT" $'1) "8"\n2) "9"' "works on another index"

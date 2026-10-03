#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# "more than 100" excludes 100 itself: write the lower bound as (100
#   ZRANGE lb:weekly (100 200 BYSCORE
#   ZCOUNT lb:weekly (100 200
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
forbid commands.redis '^ECHO' "no ECHO: ask the sorted set"
seed <<<"ZADD lb:weekly 100 ann 101 ben 150 cat 200 dan 201 eli 20 fay"
run_file commands.redis
expect_eq "$OUT" $'1) "ben"\n2) "cat"\n3) "dan"\n(integer) 3' "silver league: 100 < score <= 200"
flush
seed <<<"ZADD lb:weekly 100 x 199 y"
run_file commands.redis
expect_eq "$OUT" $'1) "y"\n(integer) 1' "works on another leaderboard"

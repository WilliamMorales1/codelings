#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# ZRANGE lb:weekly 0 2 REV WITHSCORES   (or ZREVRANGE lb:weekly 0 2 WITHSCORES)
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
forbid commands.redis '^ECHO' "no ECHO: ask the sorted set"
seed <<<"ZADD lb:weekly 170 ada 90 bob 30 cy 55 dee 120 eve"
run_file commands.redis
expect_eq "$OUT" $'1) "ada"\n2) "170"\n3) "eve"\n4) "120"\n5) "bob"\n6) "90"' "top 3 with scores"
flush
seed <<<"ZADD lb:weekly 5 a 4 b 3 c 2 d 1 e"
run_file commands.redis
expect_eq "$(members "$OUT" | tr '\n' ' ')" "3 4 5 a b c " "works on another leaderboard"

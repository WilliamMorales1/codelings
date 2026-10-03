#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# Before the ZADD:  $REDIS_CLI ZREMRANGEBYSCORE "$key" -inf "$((now - window))"
# After it:         $REDIS_CLI PEXPIRE "$key" "$window"
source "$REDISLINGS_ROOT/checks/lib.sh"

need_file limit.sh
start_redis
export_cli
got=""
for t in 0 1000 2000 3000 4000 5000; do
  got+="$(bash ./limit.sh ada $t) "
done
expect_eq "$got" "allowed allowed allowed allowed allowed denied " "5 requests allowed in 10s, the 6th denied"
expect_eq "$(bash ./limit.sh bob 5500)" "allowed" "limits are per user"
expect_eq "$(bash ./limit.sh ada 12500)" "allowed" "12.5s later the early requests have left the window"
expect_between "$(r PTTL rate:ada)" 1 10000 "rate:ada expires within the window"
expect_between "$(r ZCOUNT rate:ada -inf 2500)" 0 0 "requests older than the window were trimmed"

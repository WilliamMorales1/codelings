#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# Put WATCH stock:widget before the GET. Any write to a watched key by
# another client (even setting the same value) makes EXEC return (nil).
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
seed <<<"SET stock:widget 1"
run_file_paused commands.redis "r DECR stock:widget >/dev/null; r RPUSH orders:widget bob >/dev/null"
expect_eq "$(r GET stock:widget)" "0" "stock is 0, not negative, when bob bought the widget first"
expect_eq "$(r LRANGE orders:widget 0 -1)" "bob" "only bob's order exists"
expect_eq "$(tail -n 1 <<<"$OUT")" "(nil)" "alice's EXEC was aborted"
flush
seed <<<"SET stock:widget 1"
run_file_paused commands.redis "true"
expect_eq "$(r GET stock:widget)" "0" "without competition alice's purchase goes through"
expect_eq "$(r LRANGE orders:widget 0 -1)" "alice" "alice's order exists"

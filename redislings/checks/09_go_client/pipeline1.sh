#!/usr/bin/env bash
# REQUIRES: redis go
# HINT
# _, err := rdb.Pipelined(ctx, func(pipe redis.Pipeliner) error {
#     for i := range 2000 {
#         pipe.Incr(ctx, fmt.Sprintf("views:page:%d", i%10))
#     }
#     return nil
# })
source "$REDISLINGS_ROOT/checks/lib.sh"

go_build
start_redis
export_cli
reads() { r INFO stats | tr -d '\r' | awk -F: '$1 == "total_reads_processed" { print $2 }'; }
before=$(reads)
got=$("$PROG" 2>&1) || fail "program failed: $got"
after=$(reads)
total=0
for i in $(seq 0 9); do total=$((total + $(r GET views:page:$i))); done
expect_eq "$total" "2000" "2000 views recorded"
expect_eq "$(r GET views:page:3)" "200" "200 per page"
expect_between "$((after - before))" 1 200 "the server read the 2000 commands in a handful of batches ($((after - before)) reads)"

#!/usr/bin/env bash
# REQUIRES: redis go
# HINT
# Acquire with a TTL:  rdb.SetNX(ctx, lockKey, token, lockTTL)
# Release with a script (redis.NewScript) that DELs only if GET == token,
# and print "lost" when it returns 0:
#   release.Run(ctx, rdb, []string{lockKey}, token).Int()
source "$REDISLINGS_ROOT/checks/lib.sh"

go_build
start_redis
export_cli
key=lock:nightly-report

r SET $key someone-else PX 5000 >/dev/null
expect_eq "$("$PROG" 10 2>&1)" "busy" "a held lock is not taken"
expect_eq "$(r GET $key)" "someone-else" "and not touched"
r DEL $key >/dev/null

"$PROG" 200 >"$RDIR/a.out" 2>&1 &
pid=$!
sleep 0.1
expect_between "$(r PTTL $key)" 1 300 "the lock has a TTL of at most 300 ms"
wait "$pid"
expect_eq "$(cat "$RDIR/a.out")" $'acquired\nreleased' "short work: acquired, then released"
expect_eq "$(r EXISTS $key)" "0" "lock is free again"

"$PROG" 700 >"$RDIR/b.out" 2>&1 &
pid=$!
sleep 0.45
expect_eq "$(r SET $key worker-b NX PX 5000)" "OK" "after the TTL ran out, worker-b takes the lock"
wait "$pid"
expect_eq "$(cat "$RDIR/b.out")" $'acquired\nlost' "slow work: the program notices it lost the lock"
expect_eq "$(r GET $key)" "worker-b" "worker-b's lock was not deleted"

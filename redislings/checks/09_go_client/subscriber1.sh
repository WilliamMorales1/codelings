#!/usr/bin/env bash
# REQUIRES: redis go
# HINT
# The region is in msg.Channel ("orders:eu"), not msg.Pattern ("orders:*").
# Add the exact channel to the same PubSub, and wait for its confirmation
# before printing "ready":
#   sub.Subscribe(ctx, "control"); sub.Receive(ctx)
source "$REDISLINGS_ROOT/checks/lib.sh"

go_build
start_redis
export_cli
out="$RDIR/sub.out"
"$PROG" >"$out" 2>&1 &
pid=$!
for _ in $(seq 50); do
  grep -q '^ready$' "$out" && break
  kill -0 "$pid" 2>/dev/null || break
  sleep 0.1
done
grep -q '^ready$' "$out" || fail "program never printed ready: $(cat "$out")"
for m in "orders:eu a" "orders:us b" "orders:eu c" "payments:eu x" "orders:apac d" "control stop"; do
  r PUBLISH $m >/dev/null
done
for _ in $(seq 30); do
  kill -0 "$pid" 2>/dev/null || break
  sleep 0.1
done
if kill -0 "$pid" 2>/dev/null; then
  kill "$pid"
  fail "program still running 3s after the control message"
fi
wait "$pid"
expect_eq "$(grep -v '^ready$' "$out")" $'apac 1\neu 2\nus 1' "orders counted per region"

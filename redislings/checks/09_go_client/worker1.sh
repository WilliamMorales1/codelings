#!/usr/bin/env bash
# REQUIRES: redis go
# HINT
# Tolerate an existing group:
#   if err != nil && !strings.HasPrefix(err.Error(), "BUSYGROUP") { log.Fatal(err) }
# and acknowledge each entry once it's handled:
#   rdb.XAck(ctx, "payments", "billing", msg.ID)
source "$REDISLINGS_ROOT/checks/lib.sh"

go_build
start_redis
export_cli
for a in 10 20 30 40 50; do echo "XADD payments * amount $a"; done | seed
got=$("$PROG" 2>&1) || fail "first run failed: $got"
expect_eq "$got" "processed=5 total=150" "first run"
expect_eq "$(r XPENDING payments billing | head -n 1)" "0" "nothing pending after the first run"
for a in 7 5; do echo "XADD payments * amount $a"; done | seed
got=$("$PROG" 2>&1) || fail "second run failed (the group already exists by now): $got"
expect_eq "$got" "processed=2 total=12" "second run only sees the new payments"
expect_eq "$(r XPENDING payments billing | head -n 1)" "0" "nothing pending after the second run"

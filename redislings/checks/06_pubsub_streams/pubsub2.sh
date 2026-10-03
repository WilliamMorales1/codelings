#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# SUBSCRIBE orders:* subscribes to a channel literally named "orders:*".
# Patterns need PSUBSCRIBE orders:*
source "$REDISLINGS_ROOT/checks/lib.sh"

need_file listen.redis
start_redis
listen listen.redis 2 || fail "listen.redis did not subscribe to anything"
for m in "orders:eu eu-1" "orders:us us-1" "payments:eu pay-1" "orders:apac apac-1"; do
  r PUBLISH $m >/dev/null
done
listen_wait
got=$(grep -o -E '"(eu|us|pay|apac)-1"' <<<"$LISTENED" | tr -d '"' | paste -sd' ')
expect_eq "$got" "eu-1 us-1 apac-1" "received every orders:* message (new regions too), no payments"

#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# Queued commands only run on EXEC. When redis-cli reaches the end of the
# file it disconnects, and the server discards the open transaction.
# Note: EXEC is not a rollback mechanism. If one queued command fails at
# run time (say, INCRBY on a non-number), the others still apply.
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
require commands.redis '^MULTI' "keep the MULTI: this has to be one transaction"
for v in "100 20" "35 0"; do
  read -r a b <<<"$v"
  flush
  seed <<<"MSET account:a $a account:b $b"
  run_file commands.redis
  expect_eq "$(r MGET account:a account:b | paste -sd' ')" "$((a - 30)) $((b + 30))" "balances after moving 30 (from $a / $b)"
done

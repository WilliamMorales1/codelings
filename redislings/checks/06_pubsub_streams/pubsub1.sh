#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# PUBLISH takes exactly two arguments; a message with a space needs quotes:
#   PUBLISH orders:eu "shipped 42"
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
listen - 2 <<<"SUBSCRIBE orders:eu" || fail "test subscriber did not start"
run_file commands.redis
expect_eq "$OUT" "(integer) 1" "PUBLISH reached 1 subscriber"
listen_wait
expect_match "$LISTENED" $'"message"\n2\\) "orders:eu"\n3\\) "shipped 42"' "subscriber received \"shipped 42\" on orders:eu"

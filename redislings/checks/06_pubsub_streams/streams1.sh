#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# ID 1 is smaller than the IDs already in the stream. Use * to let the
# server generate one: XADD events * type signup user 42
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
seed <<'SEED'
XADD events 1700000000000-0 type login user 7
XADD events 1700000000000-1 type logout user 7
SEED
run_file commands.redis
expect_eq "$(r XLEN events)" "3" "events has 3 entries"
last=$(r XREVRANGE events + - COUNT 1)
expect_eq "$(tail -n +2 <<<"$last")" $'type\nsignup\nuser\n42' "the newest entry is the signup"
expect_match "$(head -n 1 <<<"$last")" '^1[7-9][0-9]{11}-0$' "its ID came from the server clock"

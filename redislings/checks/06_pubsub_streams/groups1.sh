#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# With $ the group only sees entries added after it was created, so
# XREADGROUP returns nothing. Start at the beginning:
#   XGROUP CREATE events mailer 0
# The > in XREADGROUP means "entries never delivered to this group".
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
seed <<'SEED'
XADD events 1700000000000-0 type signup user 1
XADD events 1700000000000-1 type signup user 2
XADD events 1700000000000-2 type signup user 3
SEED
run_file commands.redis
expect_eq "$(grep -c -E '"1700000000000-[01]"' <<<"$OUT")" "2" "w1 received the first two entries"
expect_eq "$(tail -n 1 <<<"$OUT")" "(integer) 1" "XACK acknowledged one entry"
expect_eq "$(r XPENDING events mailer - + 10 | head -n 2 | paste -sd' ')" "1700000000000-1 w1" "only 1700000000000-1 is still pending, owned by w1"
expect_eq "$(r XREADGROUP GROUP mailer w2 STREAMS events '>' | grep -o '1700000000000-[0-9]*' | paste -sd' ')" "1700000000000-2" "the third entry is still waiting for the next consumer"

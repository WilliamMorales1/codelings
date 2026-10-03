#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# XAUTOCLAIM events mailer alice 60000 0-0
#   (60000 ms of idleness; 0-0 = scan the pending list from the start)
# then XACK events mailer <id> <id>
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
seed <<'SEED'
XADD events 1700000000000-0 type signup user 1
XADD events 1700000000000-1 type signup user 2
XADD events 1700000000000-2 type signup user 3
XADD events 1700000000000-3 type signup user 4
XGROUP CREATE events mailer 0
XREADGROUP GROUP mailer bob COUNT 2 STREAMS events >
XCLAIM events mailer bob 0 1700000000000-0 1700000000000-1 IDLE 600000
XREADGROUP GROUP mailer carol COUNT 1 STREAMS events >
SEED
run_file commands.redis
pending() { r XPENDING events mailer - + 10 "$1" | grep -c '^1700000000000-'; }
expect_eq "$(pending bob)" "0" "bob holds nothing any more"
expect_eq "$(pending carol)" "1" "carol keeps her fresh entry"
expect_eq "$(pending alice)" "0" "alice acknowledged what she recovered"
expect_eq "$(r XREADGROUP GROUP mailer dave STREAMS events '>' | grep -o '1700000000000-[0-9]*')" "1700000000000-3" "the undelivered entry was left for later"

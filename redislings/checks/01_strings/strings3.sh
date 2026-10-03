#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# Add the NX option at the end: SET lock:report worker-b NX
# When the key exists the reply is (nil) and nothing is written.
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
seed <<<"SET lock:report worker-a"
run_file commands.redis
expect_eq "$(r GET lock:report)" "worker-a" "lock:report held by worker-a is not stolen"
expect_eq "$(r GET lock:invoice)" "worker-b" "free lock:invoice is claimed"
flush
seed <<<"SET lock:invoice worker-c"
run_file commands.redis
expect_eq "$(r GET lock:report)" "worker-b" "free lock:report is claimed"
expect_eq "$(r GET lock:invoice)" "worker-c" "lock:invoice held by worker-c is not stolen"

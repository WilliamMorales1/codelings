#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# Replace both 'lock:report' strings with KEYS[1]. With --eval, the names
# before the " , " become KEYS and the values after it ARGV.
source "$REDISLINGS_ROOT/checks/lib.sh"

need_file release.lua
start_redis
seed <<<"MSET lock:report worker-a lock:invoice worker-b"
expect_eq "$(r --eval release.lua lock:report , worker-b)" "0" "worker-b cannot release worker-a's lock"
expect_eq "$(r GET lock:report)" "worker-a" "lock:report still held by worker-a"
expect_eq "$(r --eval release.lua lock:invoice , worker-b)" "1" "worker-b releases its own lock:invoice"
expect_eq "$(r EXISTS lock:invoice)" "0" "lock:invoice is gone"
expect_eq "$(r --eval release.lua lock:report , worker-a)" "1" "worker-a releases lock:report"
expect_eq "$(r --eval release.lua lock:missing , worker-a)" "0" "releasing a lock that doesn't exist returns 0"

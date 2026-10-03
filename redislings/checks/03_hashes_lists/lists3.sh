#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# LMOVE queue:pending queue:processing RIGHT LEFT
# (RPOPLPUSH is the older, deprecated spelling of the same thing.)
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
forbid commands.redis '^RPOP ' "RPOP loses the job if the worker dies; move it instead"
seed <<<"LPUSH queue:pending job:1 job:2 job:3"
run_file commands.redis
expect_eq "$(r LRANGE queue:pending 0 -1)" $'job:3\njob:2' "oldest job left queue:pending"
expect_eq "$(r LRANGE queue:processing 0 -1)" "job:1" "and is now in queue:processing"
flush
seed <<'SEED'
LPUSH queue:pending email:77 email:78
LPUSH queue:processing email:12
SEED
run_file commands.redis
expect_eq "$(r LRANGE queue:processing 0 -1)" $'email:77\nemail:12' "works for other queues (email:77 moved to the head)"

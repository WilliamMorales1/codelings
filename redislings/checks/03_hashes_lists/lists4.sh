#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# job=$($REDIS_CLI BLPOP queue:jobs 1 | tail -n 1)
# The first line of BLPOP's reply is the key name; the job is the last line.
# On timeout the reply is nil, which redis-cli prints as an empty line.
source "$REDISLINGS_ROOT/checks/lib.sh"

need_file worker.sh
start_redis
export_cli
seed <<<"RPUSH queue:jobs a b"
bash ./worker.sh >"$RDIR/worker.out" 2>&1 &
wpid=$!
sleep 0.5
r RPUSH queue:jobs c d >/dev/null
for _ in $(seq 40); do
  kill -0 "$wpid" 2>/dev/null || break
  sleep 0.1
done
if kill -0 "$wpid" 2>/dev/null; then
  kill "$wpid"
  fail "worker.sh was still running 4s later: exit once BLPOP times out"
fi
expect_eq "$(cat "$RDIR/worker.out")" $'done a\ndone b\ndone c\ndone d' "worker processed all jobs in FIFO order, including late ones"
expect_eq "$(r LLEN queue:jobs)" "0" "queue is empty"

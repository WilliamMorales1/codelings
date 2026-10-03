#!/usr/bin/env bash
# lists4 — a worker that waits with BLPOP

REDIS_CLI=${REDIS_CLI:-redis-cli -p 6390}

while true; do
  # BLPOP prints "queue:jobs" then the job; on timeout it prints an empty line.
  job=$($REDIS_CLI BLPOP queue:jobs 1 | tail -n 1)
  [[ -z "$job" ]] && break
  echo "done $job"
done

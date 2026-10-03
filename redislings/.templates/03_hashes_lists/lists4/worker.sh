#!/usr/bin/env bash
# lists4 — a worker that waits with BLPOP
#
# Learn: polling an empty queue with LPOP in a loop either burns CPU or,
# like below, gives up the instant the queue is momentarily empty. BLPOP
# key timeout blocks until an element arrives (or timeout seconds pass,
# replying nil). Its reply is two lines: the key name, then the element.
#
# Task: producers RPUSH onto queue:jobs. Make the worker take jobs from
# the head, print "done <job>" for each, and only exit after the queue has
# stayed empty for 1 second. The check pushes more jobs after the worker
# has drained the first ones.
#
# Try it: redislings server, then run ./worker.sh while another terminal
# does: redis-cli -p 6390 RPUSH queue:jobs a b c
#

REDIS_CLI=${REDIS_CLI:-redis-cli -p 6390}

while true; do
  job=$($REDIS_CLI LPOP queue:jobs)
  [[ -z "$job" ]] && break
  echo "done $job"
done

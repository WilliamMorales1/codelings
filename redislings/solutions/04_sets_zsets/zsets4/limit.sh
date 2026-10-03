#!/usr/bin/env bash
# zsets4 — a sliding-window rate limiter

REDIS_CLI=${REDIS_CLI:-redis-cli -p 6390}
user=$1
now=$2
key="rate:$user"
window=10000
limit=5

$REDIS_CLI ZREMRANGEBYSCORE "$key" -inf "$((now - window))" >/dev/null
# The member must be unique, or two requests in the same millisecond count once.
$REDIS_CLI ZADD "$key" "$now" "$now-$RANDOM" >/dev/null
$REDIS_CLI PEXPIRE "$key" "$window" >/dev/null
count=$($REDIS_CLI ZCARD "$key")

if ((count > limit)); then
  echo denied
else
  echo allowed
fi

#!/usr/bin/env bash
# zsets4 — a sliding-window rate limiter
#
# Learn: store each request in a sorted set with its timestamp as the
# score. Before counting, drop everything older than the window with
# ZREMRANGEBYSCORE key -inf <cutoff>; what's left is exactly the requests
# of the last N milliseconds. A TTL on the key lets idle users' sets
# disappear by themselves.
#
# Task: ./limit.sh USER NOW_MS prints "allowed" or "denied". A user may
# make at most 5 requests in any 10-second (10000 ms) window. Right now
# old requests are never forgotten, so a user who was busy once is
# blocked forever, and keys never expire. Fix both: trim the window, and
# give the key a 10-second PEXPIRE.
#
# (Chapter 05 shows how to make these steps atomic.)
#

REDIS_CLI=${REDIS_CLI:-redis-cli -p 6390}
user=$1
now=$2
key="rate:$user"
window=10000
limit=5

# The member must be unique, or two requests in the same millisecond count once.
$REDIS_CLI ZADD "$key" "$now" "$now-$RANDOM" >/dev/null
count=$($REDIS_CLI ZCARD "$key")

if ((count > limit)); then
  echo denied
else
  echo allowed
fi

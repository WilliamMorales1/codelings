#!/usr/bin/env bash
# scan2 — deleting by pattern: SCAN + UNLINK

REDIS_CLI=${REDIS_CLI:-redis-cli -p 6390}

$REDIS_CLI --scan --pattern 'session:*' --count 1000 |
  xargs -r -d '\n' -n 500 $REDIS_CLI UNLINK >/dev/null

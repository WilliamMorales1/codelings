#!/usr/bin/env bash
# scan1 — SCAN instead of KEYS

REDIS_CLI=${REDIS_CLI:-redis-cli -p 6390}

# A bigger COUNT means fewer round trips; it is a hint, not a page size.
$REDIS_CLI --scan --pattern 'session:*' --count 1000 | wc -l

#!/usr/bin/env bash
# scan1 — SCAN instead of KEYS
#
# Learn: KEYS pattern walks the whole keyspace in one go, and the server
# can do nothing else until it's finished: on a big production instance
# that's seconds of outage, which is why many teams block it with ACLs
# (as the check does). SCAN returns the keyspace a slice at a time with a
# cursor. redis-cli --scan --pattern 'p*' runs the whole cursor loop for
# you and prints one key per line.
#
# Task: print how many session:* keys exist, without KEYS.
#

REDIS_CLI=${REDIS_CLI:-redis-cli -p 6390}

$REDIS_CLI KEYS 'session:*' | wc -l

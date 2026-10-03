#!/usr/bin/env bash
# info1 — reading INFO from a script
#
# Learn: INFO [section] is how you inspect a running server: memory,
# clients, persistence, replication, stats... It answers "field:value"
# lines, grouped under "# Section" headers, and every line ends with
# \r\n. Many fields share a prefix (used_memory, used_memory_rss,
# used_memory_peak, ...), so match the whole field name.
#
# Task: print exactly two lines,
#   used_memory=<bytes>
#   clients=<connected_clients>
# for a monitoring agent. The current version prints a jumble.
#

REDIS_CLI=${REDIS_CLI:-redis-cli -p 6390}

echo "used_memory=$($REDIS_CLI INFO memory | grep used_memory | cut -d: -f2)"
echo "clients=$($REDIS_CLI INFO clients | grep clients | cut -d: -f2)"

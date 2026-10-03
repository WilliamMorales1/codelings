#!/usr/bin/env bash
# scan2 — deleting by pattern: SCAN + UNLINK
#
# Learn: DEL and UNLINK take key NAMES; there is no wildcard delete, so
# DEL 'session:*' deletes a key literally called "session:*" (usually:
# nothing). Deleting by pattern means SCANning for the names and deleting
# them in batches. UNLINK is DEL that frees the memory in a background
# thread, so dropping a huge key doesn't stall the server.
#
# Task: delete every session:* key and nothing else.
#

REDIS_CLI=${REDIS_CLI:-redis-cli -p 6390}

$REDIS_CLI DEL 'session:*'

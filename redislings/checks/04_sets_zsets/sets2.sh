#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# "both" is an intersection: SINTER following:alice following:bob
# "either" is a union:       SUNIONSTORE reach:alice:bob following:alice following:bob
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
seed <<'SEED'
SADD following:alice bob carol dave
SADD following:bob carol dave erin
SEED
run_file commands.redis
expect_eq "$(members "$OUT")" $'carol\ndave' "prints who both follow"
expect_eq "$(r SMEMBERS reach:alice:bob | sort)" $'bob\ncarol\ndave\nerin' "reach:alice:bob holds the union"
flush
seed <<'SEED'
SADD following:alice zed
SADD following:bob yan zed
SEED
run_file commands.redis
expect_eq "$(members "$OUT")" "zed" "works on other data too"

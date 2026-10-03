#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# SET user:1:token tok-new KEEPTTL
# PERSIST user:1:profile
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
seed <<'SEED'
SET user:1:token tok-old EX 100
SET user:1:profile "{\"name\":\"Ada\"}" EX 100
SEED
run_file commands.redis
expect_eq "$(r GET user:1:token)" "tok-new" "token rotated"
expect_between "$(r TTL user:1:token)" 90 100 "token keeps its remaining TTL"
expect_eq "$(r EXISTS user:1:profile)" "1" "profile still exists"
expect_eq "$(r TTL user:1:profile)" "-1" "profile has no TTL any more"

#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# `SET key Ada Lovelace` sends three arguments after SET, and the third one
# ("Lovelace") is parsed as an option, hence "ERR syntax error".
# Wrap the value in double quotes: SET user:1:name "Ada Lovelace"
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
run_file commands.redis
expect_eq "$(r GET user:1:name)" "Ada Lovelace" "user:1:name"
expect_eq "$(r GET user:1:lang)" "en" "user:1:lang"

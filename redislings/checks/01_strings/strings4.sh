#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# One line: SET config:active v2 GET
# It prints the old value (or (nil) if there was none).
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
n=$(strip_comments commands.redis | wc -l)
expect_eq "$n" "1" "exactly one command"
forbid commands.redis '^(ECHO|GETSET)' "no ECHO, and GETSET is deprecated: use SET's GET option"
for old in v1 v1.9-hotfix; do
  flush
  seed <<<"SET config:active $old"
  run_file commands.redis
  expect_eq "$OUT" "\"$old\"" "prints the previous version ($old)"
  expect_eq "$(r GET config:active)" "v2" "config:active is now v2"
done

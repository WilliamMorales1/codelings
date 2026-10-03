#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# PFADD visitors:2026-09-29 u1 u2 new1 new2
# PFMERGE visitors:week visitors:2026-09-28 visitors:2026-09-29
# PFCOUNT visitors:week
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
{
  printf 'PFADD visitors:2026-09-28'
  for i in $(seq 0 999); do printf ' u%d' "$i"; done
  echo
} | seed
run_file commands.redis
expect_eq "$(r TYPE visitors:week)" "string" "visitors:week is a HyperLogLog (stored as a string)"
expect_between "$(r PFCOUNT visitors:2026-09-29)" 4 4 "4 visitors today"
n=$(sed -n -E 's/^\(integer\) //p' <<<"$OUT" | tail -n 1)
expect_between "${n:-none}" 985 1020 "printed about 1002 unique visitors this week"

#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# The offset comes first, the bit value second: SETBIT active:2026-09-29 5 1
# "active on both days" is an AND, not an OR.
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
seed <<'SEED'
SETBIT active:2026-09-28 1 1
SETBIT active:2026-09-28 5 1
SETBIT active:2026-09-28 7 1
SEED
run_file commands.redis
expect_eq "$(r GETBIT active:2026-09-29 5)$(r GETBIT active:2026-09-29 9)" "11" "users 5 and 9 active on the 29th"
expect_eq "$(r BITCOUNT active:2026-09-29)" "2" "nobody else active on the 29th"
expect_eq "$(r GETBIT active:both 5)$(r BITCOUNT active:both)" "11" "active:both holds just user 5"
expect_eq "$(tail -n 1 <<<"$OUT")" "(integer) 1" "printed the count"

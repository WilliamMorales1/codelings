#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# The table form of register_function takes flags:
#   redis.register_function{
#     function_name = 'get_count',
#     callback = get_count,
#     flags = { 'no-writes' },
#   }
source "$REDISLINGS_ROOT/checks/lib.sh"

need_file counters.lua
start_redis
got=$(r FUNCTION LOAD REPLACE "$(cat counters.lua)")
expect_eq "$got" "counters" "FUNCTION LOAD registers the 'counters' library"
out=""
for _ in 1 2 3 4; do out+="$(r FCALL incr_capped 1 counter:signups 3) "; done
expect_eq "$out" "1 2 3 3 " "incr_capped stops at the cap"
expect_eq "$(r FCALL_RO get_count 1 counter:signups)" "3" "FCALL_RO get_count works"
expect_eq "$(r FCALL_RO get_count 1 counter:none)" "0" "get_count of a missing counter is 0"

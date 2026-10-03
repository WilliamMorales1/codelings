#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# GET returns a string ("5"), or false when the key is missing, and Lua
# refuses to compare a string with a number. Convert first:
#   local stock = tonumber(redis.call('GET', KEYS[1]) or 0)
source "$REDISLINGS_ROOT/checks/lib.sh"

need_file stock.lua
start_redis
seed <<<"SET stock:widget 2"
expect_eq "$(r --eval stock.lua stock:widget)" "1" "2 in stock: returns 1"
expect_eq "$(r --eval stock.lua stock:widget)" "0" "1 in stock: returns 0"
expect_eq "$(r --eval stock.lua stock:widget)" "-1" "sold out: returns -1"
expect_eq "$(r GET stock:widget)" "0" "stock never goes negative"
expect_eq "$(r --eval stock.lua stock:gadget)" "-1" "missing key: returns -1"
expect_eq "$(r EXISTS stock:gadget)" "0" "missing key is not created"
r SET stock:widget 5 >/dev/null
pids=()
for i in $(seq 20); do
  r --eval stock.lua stock:widget >"$RDIR/buy.$i" &
  pids+=($!)
done
# A bare `wait` would also wait for the server.
wait "${pids[@]}"
expect_eq "$(cat "$RDIR"/buy.* | grep -cv -- '-1')" "5" "20 concurrent buyers, exactly 5 succeed"
expect_eq "$(r GET stock:widget)" "0" "stock ends at 0"

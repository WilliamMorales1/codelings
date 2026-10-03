#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# HINCRBY user:7 visits 1
# HINCRBY cart:7 sku:42 2
# HDEL cart:7 sku:13     (a quantity of 0 is still a field in the cart)
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
for v in "3 1" "40 5"; do
  read -r visits qty <<<"$v"
  flush
  seed <<SEED
HSET user:7 name Grace visits $visits
HSET cart:7 sku:42 $qty sku:13 2 sku:99 1
SEED
  run_file commands.redis
  expect_eq "$(r HGET user:7 visits)" "$((visits + 1))" "visits went from $visits to $((visits + 1))"
  expect_eq "$(r HGET cart:7 sku:42)" "$((qty + 2))" "sku:42 went from $qty to $((qty + 2))"
  expect_eq "$(r HEXISTS cart:7 sku:13)" "0" "sku:13 is gone from the cart"
  expect_eq "$(r HGET cart:7 sku:99)" "1" "other cart items untouched"
done

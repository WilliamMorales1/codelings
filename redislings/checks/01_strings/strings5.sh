#!/usr/bin/env bash
# REQUIRES: redis
# HINT
# MSET k1 v1 k2 v2 k3 v3   then   MGET k1 k2 k3
# Keys: product:1:price, product:2:price, product:3:price.
source "$REDISLINGS_ROOT/checks/lib.sh"

start_redis
expect_eq "$(strip_comments commands.redis | wc -l)" "2" "two commands: one MSET, one MGET"
require commands.redis '^MSET ' "use MSET to write the prices"
require commands.redis '^MGET ' "use MGET to read them"
run_file commands.redis
expect_eq "$(r KEYS '*' | sort)" $'product:1:price\nproduct:2:price\nproduct:3:price' "exactly the three product:<id>:price keys"
expect_eq "$OUT" $'OK\n1) "9.99"\n2) "24.50"\n3) "3.75"' "MGET output, products 1, 2, 3"

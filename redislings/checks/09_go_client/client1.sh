#!/usr/bin/env bash
# REQUIRES: redis go
# HINT
# switch {
# case errors.Is(err, redis.Nil): fmt.Printf("%s is not cached\n", key)
# case err != nil:                log.Fatal(err)
# default:                        fmt.Printf("%s = %s\n", key, val)
# }
# and pass time.Minute instead of 0 to Set.
source "$REDISLINGS_ROOT/checks/lib.sh"

go_build
start_redis
export_cli
seed <<<'MSET greeting hello city "New York"'
got=$("$PROG" greeting nope city 2>&1) || fail "program failed: $got"
expect_eq "$got" $'greeting = hello\nnope is not cached\ncity = New York' "output for a mix of hits and misses"
expect_between "$(r TTL client1:last-run)" 50 60 "client1:last-run expires after a minute"

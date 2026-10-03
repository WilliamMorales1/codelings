#!/usr/bin/env bash
# REQUIRES: ip nft curl unshare
# HINT
# Without a port, dnat keeps the original destination port (80), and nothing
# listens on a's port 80. Name both: `dnat to 10.1.0.2:8080`.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_nat
bg a "$(tmpfile)" netlings serve http -addr :8080 -name a
wait_listen a 8080
sandbox_here "a 10.1.0.2 (web app on 8080) - r 203.0.113.1 - b. Load with 'ip netns exec r nft -f ruleset.nft'," \
  "then 'ip netns exec b curl -m2 http://203.0.113.1/'."

load_ruleset r ruleset.nft
got=$(ns b curl -s --max-time 2 http://203.0.113.1/) || fail "b cannot fetch http://203.0.113.1/"
expect_eq "$got" "hello from a" "http://203.0.113.1/ is served by a's port 8080"

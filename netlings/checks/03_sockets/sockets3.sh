#!/usr/bin/env bash
# REQUIRES: ss ip unshare
# HINT
# Give the address explicitly: -addr 127.0.0.1:7000. Afterwards
# `ip netns exec b ss -tln` should show 127.0.0.1:7000 next to *:7001.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_pair
sandbox_here "a (10.0.0.1) <-> b (10.0.0.2). Your script runs inside b: 'ip netns exec b bash setup.sh'," \
  "then 'ip netns exec b ss -tlnp'."

run_setup setup.sh b
wait_listen b 7000
wait_listen b 7001
local=$(ns b ss -Htln 'sport = :7000' | awk '{print $4}')
expect_eq "$local" 127.0.0.1:7000 "port 7000 is bound to loopback only"
ns b timeout 1 bash -c 'exec 3<>/dev/tcp/127.0.0.1/7000' || fail "b itself cannot connect to 127.0.0.1:7000"
ok "b can reach its admin port"
can_tcp a 10.0.0.2 7000 && fail "a can still connect to 10.0.0.2:7000"
ok "a cannot reach port 7000"
can_tcp a 10.0.0.2 7001 || fail "a cannot reach the public port 7001 any more"
ok "a can reach port 7001"

#!/usr/bin/env bash
# REQUIRES: ip tc ping jq unshare
# HINT
# `tc qdisc show dev a0` (inside a) prints "delay 100us" (or 100ns): tc's
# default time unit is not milliseconds. Write the unit: `delay 100ms`.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_pair
sandbox_here "a (10.0.0.1) <-> b (10.0.0.2). 'bash setup.sh', then 'ip netns exec a ping -c3 10.0.0.2'."

run_setup
q=$(ns a tc -j qdisc show dev a0 | jq -r '.[0].kind')
expect_eq "$q" netem "a0 has a netem qdisc"
expect_eq "$(ns b tc -j qdisc show dev b0 | jq -r '[.[] | select(.kind=="netem")] | length')" 0 "nothing added on b0"
avg=$(ns a ping -c3 -i0.2 -q 10.0.0.2 | awk -F/ '/^rtt/ {printf "%d", $5}')
[[ -n $avg ]] || fail "ping got no replies"
((avg >= 95 && avg <= 160)) || fail "average RTT is ${avg}ms, expected about 100ms"
ok "average RTT ${avg}ms"

#!/usr/bin/env bash
# REQUIRES: ip bridge ping jq unshare
# HINT
# p3 is not enslaved (`ip -n sw link set p3 master br0`), and a new bridge is
# DOWN like any new interface (`ip -n sw link set br0 up`). `bridge -n sw link`
# lists the ports and their state (forwarding, ...).
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_lan 3 --no-bridge
sandbox_here "h1..h3 are cabled to p1..p3 in sw, no bridge yet. 'bash setup.sh' applies your file."

run_setup
settle_bridge sw
ports=$(bridge -n sw -j link show | jq -r '[.[] | select(.master=="br0") | .ifname] | sort | join(" ")')
expect_eq "$ports" "p1 p2 p3" "ports of br0"
for pair in "h1 10.0.0.2" "h1 10.0.0.3" "h2 10.0.0.3" "h3 10.0.0.1"; do
  set -- $pair
  expect_ping "$1" "$2"
done

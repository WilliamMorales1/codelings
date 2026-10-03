#!/usr/bin/env bash
# REQUIRES: ip ping jq unshare
# HINT
# `ip link show eth0` is h1's OWN MAC. The neighbour's is in the neighbour
# table after the ping: `ip neigh show 10.0.0.3` prints
# "10.0.0.3 dev eth0 lladdr xx:xx:... REACHABLE". `ip -j neigh ... | jq -r '.[0].lladdr'`
# or awk '{print $5}' gets the address out.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_lan 3
sandbox_here "h1..h3 on bridge br0 in sw. Try 'ip netns exec h1 bash mac.sh' and 'ip -n h1 neigh'."

want=$(ip -n h3 -j link show eth0 | jq -r '.[0].address')
capture mac.sh h1
expect_eq "$OUT" "$want" "MAC of 10.0.0.3 (h3's eth0)"

#!/usr/bin/env bash
# REQUIRES: ip bridge ping jq unshare
# HINT
# p2 is a member of VLAN 10, but its untagged frames still land in the
# default VLAN 1 (look at `bridge -n sw vlan show`: which VLAN is PVID on
# p2?). Add `pvid untagged` for p2 as well.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_lan 3
sandbox_here "h1..h3 (10.0.0.1-3) on br0 in sw, no VLANs yet. 'bash setup.sh' applies your file;" \
  "'bridge -n sw vlan show' shows the result."

run_setup
expect_eq "$(ip -n sw -j -d link show br0 | jq -r '.[0].linkinfo.info_data.vlan_filtering')" 1 "br0 filters VLANs"
pvid() { bridge -n sw -j vlan show dev "$1" | jq -r '[.[0].vlans[] | select(.flags // [] | index("PVID")) | .vlan] | first // "none"'; }
expect_eq "$(pvid p1)" 10 "p1 access port in VLAN 10"
expect_eq "$(pvid p2)" 10 "p2 access port in VLAN 10"
expect_eq "$(pvid p3)" 20 "p3 access port in VLAN 20"
expect_ping h1 10.0.0.2 "h1 <-> h2 (VLAN 10)"
expect_no_ping h1 10.0.0.3 "h1 cannot reach h3 (VLAN 20)"
expect_no_ping h2 10.0.0.3 "h2 cannot reach h3 (VLAN 20)"

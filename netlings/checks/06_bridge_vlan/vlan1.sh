#!/usr/bin/env bash
# REQUIRES: ip ping jq unshare
# HINT
# h2's eth0.10 uses `id 100`; frames tagged 100 are ignored by h1's VLAN 10.
# Use id 10 on both. VLAN 20 is the same three commands per host with 20.
# `ip -d link show eth0.10` shows "vlan protocol 802.1Q id 10".
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
newns h1 h2
wire h1 eth0 h2 eth0
sandbox_here "h1 eth0 <-> h2 eth0, no addresses. 'bash setup.sh' applies your file."

run_setup
for h in h1 h2; do
  for v in 10 20; do
    id=$(ip -n $h -j -d link show eth0.$v 2>/dev/null | jq -r '.[0].linkinfo.info_data.id // "none"')
    expect_eq "$id" "$v" "$h eth0.$v carries VLAN ID $v"
  done
done
expect_ping h1 10.10.0.2 "h1 reaches h2 on VLAN 10"
expect_ping h1 10.20.0.2 "h1 reaches h2 on VLAN 20"

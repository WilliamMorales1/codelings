#!/usr/bin/env bash
# REQUIRES: ip ping jq unshare
# HINT
# Look at `ip link show lo`: the state says DOWN. An address on a DOWN
# interface is configured but unusable. `ip link set DEV up` brings it up.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
sandbox_here "Fresh namespace, lo is DOWN. 'bash setup.sh' applies your file."

run_setup
lo=$(ip -j addr show lo)
[[ $(jq -r '.[0].flags | index("UP") != null' <<<"$lo") == true ]] || fail "lo is still DOWN"
ok "lo is UP"
expect_eq "$(jq -r '[.[0].addr_info[] | select(.local == "10.255.0.1") | .prefixlen] | first' <<<"$lo")" 32 "10.255.0.1 is on lo as a /32"
expect_ping - 127.0.0.1
expect_ping - 10.255.0.1

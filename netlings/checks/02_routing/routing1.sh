#!/usr/bin/env bash
# REQUIRES: ip ping jq unshare
# HINT
# b0 has to move into namespace b, not a. And a cable needs both ends plugged
# in: a veth pair only carries traffic once BOTH ends are UP (`ip -n a link`
# shows a0 as "state LOWERLAYERDOWN" / "M-DOWN" until then).
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
sandbox_here "Empty sandbox. 'bash setup.sh' runs your script; 'ip netns list' shows what exists."

run_setup
for n in a b; do
  [[ -e /run/netns/$n ]] || fail "namespace $n does not exist"
done
ok "namespaces a and b exist"
expect_eq "$(ip -n a -j addr show a0 2>/dev/null | jq -r '.[0].addr_info[] | select(.family=="inet") | "\(.local)/\(.prefixlen)"')" 10.0.0.1/24 "a0 in a has 10.0.0.1/24"
expect_eq "$(ip -n b -j addr show b0 2>/dev/null | jq -r '.[0].addr_info[] | select(.family=="inet") | "\(.local)/\(.prefixlen)"')" 10.0.0.2/24 "b0 in b has 10.0.0.2/24"
expect_ping a 10.0.0.2
expect_ping b 10.0.0.1

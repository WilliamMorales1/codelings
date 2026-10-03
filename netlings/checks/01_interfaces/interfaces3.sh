#!/usr/bin/env bash
# REQUIRES: ip ping jq unshare
# HINT
# A link has two ends. b0 still has MTU 1500, so it drops every frame bigger
# than that, no error, no ICMP. Compare `ip -n a link show a0` with
# `ip -n b link show b0`, and set b0's MTU too.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_pair
sandbox_here "a (10.0.0.1) <-> b (10.0.0.2) are wired up. 'bash setup.sh' applies your file."

run_setup
expect_eq "$(ip -n a -j link show a0 | jq '.[0].mtu')" 9000 "a0 MTU"
expect_eq "$(ip -n b -j link show b0 | jq '.[0].mtu')" 9000 "b0 MTU"
ns a ping -c1 -W1 -q -M do -s 8972 10.0.0.2 >/dev/null || fail "a cannot send a 9000-byte packet to b"
ok "9000-byte ping a -> b"
ns b ping -c1 -W1 -q -M do -s 8972 10.0.0.1 >/dev/null || fail "b cannot send a 9000-byte packet to a"
ok "9000-byte ping b -> a"

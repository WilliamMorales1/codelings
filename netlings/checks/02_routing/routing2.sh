#!/usr/bin/env bash
# REQUIRES: ip ping jq unshare
# HINT
# A route either says "dev X" (destination is on this wire) or "via GW"
# (hand it to the router GW, which must itself be on one of my wires). From b,
# the router is 10.2.0.1. Watch it happen: `ip -n b neigh` after a failed ping
# shows 10.1.0.2 as FAILED/INCOMPLETE.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_router --bare
ns r sysctl -qw net.ipv4.ip_forward=1
sandbox_here "a - r - b is wired, r forwards, no routes yet. 'bash setup.sh' applies your file."

run_setup
expect_ping a 10.2.0.2 "a reaches b through r"
expect_eq "$(ip -n b -j route show default | jq length)" 0 "b has no default route"
g=$(ip -n b -j route get 10.1.0.2 | jq -r '.[0].gateway // "none"')
expect_eq "$g" 10.2.0.1 "b sends traffic for 10.1.0.0/24 to the router"

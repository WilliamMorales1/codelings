#!/usr/bin/env bash
# REQUIRES: ip ping unshare
# HINT
# The script ran in the sandbox's own namespace, which is not in the path at
# all. Run sysctl inside r: `ip netns exec r sysctl -w net.ipv4.ip_forward=1`.
# Check with `ip netns exec r sysctl net.ipv4.ip_forward`.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_router --bare
ip -n a route add default via 10.1.0.1
ip -n b route add default via 10.2.0.1
sandbox_here "a - r - b with default routes, forwarding off everywhere. 'bash setup.sh' applies your file."

run_setup
expect_eq "$(ns r sysctl -n net.ipv4.ip_forward)" 1 "forwarding on in r"
expect_eq "$(sysctl -n net.ipv4.ip_forward)" 0 "forwarding off in the sandbox's own namespace"
expect_ping a 10.2.0.2 "a reaches b through r"

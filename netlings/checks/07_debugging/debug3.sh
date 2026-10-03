#!/usr/bin/env bash
# REQUIRES: ip ping jq unshare
# HINT
# The ping reply is "Time to live exceeded" and tracepath alternates between
# 10.12.0.1 and 10.12.0.2: r1 and r2 keep handing the packet to each other.
# `ip -n r2 route get 10.3.0.2` says "via 10.12.0.1", although b is directly
# connected to r2. Longest prefix wins: look for a route more specific than /24
# in `ip -n r2 route`, and delete it (`ip -n r2 route del PREFIX`).
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
newns a r1 r2 b
wire a a0 r1 r1a
wire r1 r1b r2 r2a
wire r2 r2b b b0
addr a a0 10.1.0.2/24
addr r1 r1a 10.1.0.1/24
addr r1 r1b 10.12.0.1/24
addr r2 r2a 10.12.0.2/24
addr r2 r2b 10.3.0.1/24
addr b b0 10.3.0.2/24
ns r1 sysctl -qw net.ipv4.ip_forward=1
ns r2 sysctl -qw net.ipv4.ip_forward=1
ip -n a route add default via 10.1.0.1
ip -n b route add default via 10.3.0.1
ip -n r1 route add 10.3.0.0/24 via 10.12.0.2
ip -n r2 route add default via 10.12.0.1
ip -n r2 route add 10.3.0.0/25 via 10.12.0.1
sandbox_here "The broken network from the ticket. Investigate, then 'bash fix.sh'."

run_setup fix.sh
expect_ping a 10.3.0.2 "a reaches b"
expect_eq "$(ip -n r2 -j route get 10.3.0.2 | jq -r '.[0].dev')" r2b "r2 delivers 10.3.0.2 directly on r2b"
expect_eq "$(ip -n r1 -j route get 10.3.0.2 | jq -r '.[0].gateway')" 10.12.0.2 "r1 still routes via r2"
expect_eq "$(ip -n r2 -j route show default | jq -r '.[0].gateway')" 10.12.0.1 "r2 keeps its default route"

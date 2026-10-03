#!/usr/bin/env bash
# REQUIRES: ip ping jq unshare
# HINT
# c answers a by sending to its default gateway, r2. Does r2 know where
# 10.1.0.0/24 is? `ip -n r2 route` says no. Give r2 a route to 10.1.0.0/24
# via r1's address on their shared link, 10.12.0.1.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
newns a r1 r2 c
wire a a0 r1 r1a
wire r1 r1b r2 r2a
wire r2 r2b c c0
addr a a0 10.1.0.2/24
addr r1 r1a 10.1.0.1/24
addr r1 r1b 10.12.0.1/24
addr r2 r2a 10.12.0.2/24
addr r2 r2b 10.3.0.1/24
addr c c0 10.3.0.2/24
ns r1 sysctl -qw net.ipv4.ip_forward=1
ns r2 sysctl -qw net.ipv4.ip_forward=1
ip -n a route add default via 10.1.0.1
ip -n c route add default via 10.3.0.1
sandbox_here "a - r1 - r2 - c wired, routers forward, only default routes on a and c." \
  "'bash setup.sh' applies your file; 'ip netns exec a tracepath -n 10.3.0.2' shows the path."

run_setup
for r in r1 r2; do
  expect_eq "$(ip -n $r -j route show default | jq length)" 0 "no default route on $r"
done
expect_eq "$(ip -n r2 -j route get 10.1.0.5 | jq -r '.[0].gateway // "none"')" 10.12.0.1 "r2 sends 10.1.0.0/24 to r1"
expect_ping a 10.3.0.2 "a reaches c"
expect_ping c 10.1.0.2 "c reaches a"

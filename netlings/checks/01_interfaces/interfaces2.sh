#!/usr/bin/env bash
# REQUIRES: ip jq unshare
# HINT
# `ip -br addr show dummy0` shows 192.0.2.10/32. Write the address as
# 192.0.2.10/24. Then `ip route` shows "192.0.2.0/24 dev dummy0 proto kernel
# scope link", the route the kernel made for you.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
sandbox_here "'bash setup.sh' applies your file; then compare 'ip route' and 'ip route get 192.0.2.99'."

run_setup
a=$(ip -j addr show dev dummy0)
expect_eq "$(jq -r '.[0].addr_info[] | select(.family=="inet") | "\(.local)/\(.prefixlen)"' <<<"$a")" 192.0.2.10/24 "IPv4 address on dummy0"
expect_eq "$(jq -r '.[0].addr_info[] | select(.family=="inet6" and .scope=="global") | "\(.local)/\(.prefixlen)"' <<<"$a")" 2001:db8::10/64 "IPv6 address on dummy0"
r=$(ip -j route show 192.0.2.0/24)
expect_eq "$(jq -r '.[0].dev // "none"' <<<"$r")" dummy0 "connected route 192.0.2.0/24 exists"
g=$(ip -j route get 192.0.2.99 2>&1) || fail "ip route get 192.0.2.99: $g"
expect_eq "$(jq -r '.[0].dev' <<<"$g")" dummy0 "192.0.2.99 is reached via dummy0"
expect_eq "$(jq -r '.[0].gateway // "direct"' <<<"$g")" direct "no gateway needed for 192.0.2.99"

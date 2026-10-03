#!/usr/bin/env bash
# REQUIRES: ip nft jq curl unshare
# HINT
# Masquerade the packets that LEAVE towards the internet, i.e. whose output
# interface is r1: `oifname "r1" masquerade`. (Rewriting on r0 would hide b
# from a, the wrong way round.) `ip netns exec r conntrack -L` is not
# installed, but `nft list ruleset` counters help if you add some.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_nat
bg b "$(tmpfile)" netlings serve http -addr :80 -name internet
wait_listen b 80
sandbox_here "a 10.1.0.2 - r - b 203.0.113.2 (web server). Load with 'ip netns exec r nft -f ruleset.nft'," \
  "then 'ip netns exec a curl -m2 http://203.0.113.2/whoami'."

load_ruleset r ruleset.nft
[[ -z $(ip -n b route show 10.1.0.0/24) ]] || fail "b must not get a route to 10.1.0.0/24; NAT is the point"
w=$(ns a curl -s --max-time 2 http://203.0.113.2/whoami) || fail "a cannot fetch http://203.0.113.2/whoami"
ok "a reaches the web server on b"
expect_eq "$(jq -r .remote_ip <<<"$w")" 203.0.113.1 "b sees r's public address as the client"

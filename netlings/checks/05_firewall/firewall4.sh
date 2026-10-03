#!/usr/bin/env bash
# REQUIRES: ip nft jq unshare
# HINT
# On incoming packets, daddr is h1 itself; the attacker is the SOURCE:
# `ip saddr @blocklist drop`. And add 8080 to the port set:
# `tcp dport { 22, 80, 443, 8080 } accept`.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_lan 3
serve_ports h1 22 80 443 8080 9000
sandbox_here "h1 10.0.0.1 (server), h2 10.0.0.2, h3 10.0.0.3. Load with 'ip netns exec h1 nft -f ruleset.nft'."

load_ruleset h1 ruleset.nft
els=$(nft_json h1 list set inet filter blocklist | jq -c '[.nftables[] | .set? // empty | .elem[]?]')
expect_eq "$els" '["10.0.0.3"]' "named set blocklist holds 10.0.0.3"
for p in 22 80 443 8080; do expect_tcp h2 10.0.0.1 $p; done
expect_no_tcp h2 10.0.0.1 9000
expect_ping h2 10.0.0.1
for p in 22 80; do expect_no_tcp h3 10.0.0.1 $p; done
expect_no_ping h3 10.0.0.1

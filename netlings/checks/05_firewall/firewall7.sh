#!/usr/bin/env bash
# REQUIRES: ip nft curl unshare
# HINT
# Add `ct state established,related accept` near the top of the chain.
# Accepting "tcp sport 80" instead would let anyone in who simply sends from
# port 80; conntrack only accepts real replies.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_pair
serve_ports a 80
serve_ports b 22 80
sandbox_here "a 10.0.0.1 (web server) <-> b 10.0.0.2 (ports 22, 80). Load with 'ip netns exec b nft -f ruleset.nft'."

load_ruleset b ruleset.nft
expect_tcp a 10.0.0.2 22
expect_no_tcp a 10.0.0.2 80
got=$(ns b curl -s --max-time 2 http://10.0.0.1/) || fail "b cannot fetch http://10.0.0.1/ (the replies are dropped)"
expect_eq "$got" "hello from a" "b fetches from a"
expect_ping b 10.0.0.1
if nft_json b list ruleset | grep -q '"sport"'; then
  fail "the ruleset matches on source ports; use connection tracking instead"
fi
ok "no source-port hacks"

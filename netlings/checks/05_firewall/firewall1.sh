#!/usr/bin/env bash
# REQUIRES: ip nft jq unshare
# HINT
# Add as the first line inside the chain:
#     type filter hook input priority filter; policy drop;
# Then the trailing `drop` rule is redundant (the policy does it), though
# harmless. `nft list chains` shows a hook only for base chains.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_pair
serve_ports b 22 80 8080
sandbox_here "a (10.0.0.1) -> b (10.0.0.2: ports 22, 80, 8080 open)." \
  "Load with 'ip netns exec b nft -f ruleset.nft'; test with 'ip netns exec a curl -m1 10.0.0.2'."

load_ruleset b ruleset.nft
hook=$(nft_json b list chains | jq -r '.nftables[] | select(.chain.name=="input") | .chain.hook // "none"')
expect_eq "$hook" input "chain input is attached to the input hook"
expect_tcp a 10.0.0.2 22
expect_ping a 10.0.0.2
expect_no_tcp a 10.0.0.2 80
expect_no_tcp a 10.0.0.2 8080
ns b timeout 1 bash -c 'exec 3<>/dev/tcp/127.0.0.1/8080' 2>/dev/null || fail "b cannot reach its own port 8080 over lo"
ok "b still reaches itself over lo"

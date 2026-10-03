#!/usr/bin/env bash
# REQUIRES: ip nft jq unshare
# HINT
# The drop rule ends evaluation, so the counter rule after it is never
# reached. Put the counter in the same rule, before the verdict:
#     tcp dport 23 counter drop
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_pair
serve_ports b 23 80
sandbox_here "a (10.0.0.1) -> b (10.0.0.2: ports 23 and 80). Load with 'ip netns exec b nft -f ruleset.nft'," \
  "then 'ip netns exec a curl -m1 telnet://10.0.0.2:23' and 'ip netns exec b nft list ruleset'."

load_ruleset b ruleset.nft
for _ in 1 2 3; do
  can_tcp a 10.0.0.2 23 && fail "a reached port 23: telnet should be dropped"
done
ok "3 telnet attempts were dropped"
expect_tcp a 10.0.0.2 80
pk=$(nft_json b list ruleset | jq '[.nftables[] | .rule? // empty | .expr[] | .counter? // empty | .packets] | add // 0')
((pk >= 3)) || fail "the counters saw $pk packets, expected at least 3"
ok "counters saw $pk packets"

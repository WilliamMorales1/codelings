#!/usr/bin/env bash
# REQUIRES: ip nft unshare
# HINT
# Move `ip saddr 10.0.0.3 drop` above `tcp dport 22 accept` (and above the
# ct state rule too, so already-open sessions from h3 are cut as well).
# `nft -a list ruleset` shows rule handles if you prefer editing live.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_lan 3
serve_ports h1 22 80
sandbox_here "h1 10.0.0.1 (server, 22+80), h2 10.0.0.2 (office), h3 10.0.0.3 (bad) on one bridge." \
  "Load with 'ip netns exec h1 nft -f ruleset.nft'."

load_ruleset h1 ruleset.nft
expect_tcp h2 10.0.0.1 22
expect_tcp h2 10.0.0.1 80
expect_ping h2 10.0.0.1
expect_no_tcp h3 10.0.0.1 22
expect_no_tcp h3 10.0.0.1 80
expect_no_ping h3 10.0.0.1

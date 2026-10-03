#!/usr/bin/env bash
# REQUIRES: ip curl jq unshare
# HINT
# A header is "Name: value", with a colon; "X-Token=netlings" is not a
# header at all (curl sends nothing sensible). You need two -H options:
#   -H 'Accept: application/json' -H 'X-Token: netlings'
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_web
sandbox_here "a (10.0.0.1) -> b (10.0.0.2, HTTP on 80). Try 'ip netns exec a bash request.sh'."

capture request.sh a
jq -e . >/dev/null 2>&1 <<<"$OUT" || fail "the answer is not JSON: $OUT"
expect_eq "$(jq -r .status <<<"$OUT")" ok "GET /api/status answered ok"

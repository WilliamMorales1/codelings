#!/usr/bin/env bash
# REQUIRES: ip curl jq unshare
# HINT
# The server says: Content-Type must be application/json. Add
# -H 'Content-Type: application/json', or replace `-X POST -d` with `--json`.
# (-X POST is redundant anyway: -d already makes it a POST.)
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_web
sandbox_here "b (10.0.0.2) has POST /api/items. Try 'ip netns exec a bash post.sh'."

capture post.sh a
expect_eq "$(jq -r .id <<<"$OUT" 2>/dev/null)" 42 "item created (got: $OUT)"
expect_eq "$(jq -r .name <<<"$OUT")" router "item name"

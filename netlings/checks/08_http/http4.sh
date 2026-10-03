#!/usr/bin/env bash
# REQUIRES: ip curl unshare
# HINT
# Add -L so curl follows the Location headers, and extend the -w format:
#   -w '%{http_code} %{url_effective}\n%{num_redirects}\n'
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
topo_web
sandbox_here "b (10.0.0.2): /old redirects twice. Try 'ip netns exec a curl -i http://10.0.0.2/old'."

capture status.sh a
mapfile -t lines <<<"$OUT"
expect_eq "${lines[0]:-}" "200 http://10.0.0.2/final" "line 1: final status and URL"
expect_eq "${lines[1]:-}" "2" "line 2: redirects followed"

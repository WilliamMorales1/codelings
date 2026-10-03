#!/usr/bin/env bash
# REQUIRES: k6 jq curl
# HINT
# k6 calls them `vus`, and the duration needs a unit:
#   export const options = {
#     vus: 5,
#     duration: '3s',
#   };
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file script.js
expect_eq "$(k6_opt '.vus')" "5" "options.vus"
expect_eq "$(k6_opt '.duration')" '"3s"' "options.duration"
start_target
k6_ok script.js
n=$(stat_count 'GET /api/items 200')
((n >= 10 && n <= 25)) || fail "expected roughly 15 requests (5 VUs x 3s, 1s sleep), got $n"
ok "$n requests from 5 VUs over 3s"

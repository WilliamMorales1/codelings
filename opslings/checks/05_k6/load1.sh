#!/usr/bin/env bash
# REQUIRES: k6 jq curl
# HINT
# The default export is imported without braces:
#   import http from 'k6/http';
# and the URL is built from the environment:
#   http.get(`${__ENV.BASE_URL}/api/items`);
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file script.js
start_target
k6_ok --iterations 5 script.js
expect_eq "$(stat_count 'GET /api/items 200')" "5" "GET /api/items answered 200, once per iteration"
expect_eq "$(curl -s "$TARGET_URL/__stats" | jq .total)" "5" "no other requests"

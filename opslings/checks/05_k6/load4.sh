#!/usr/bin/env bash
# REQUIRES: k6 jq curl
# HINT
# Encode the body and say so:
#   http.post(`${BASE}/api/login`,
#     JSON.stringify({ username: 'ops', password: 'lings' }),
#     { headers: { 'Content-Type': 'application/json' } });
# and send the scheme with the token:
#   headers: { Authorization: `Bearer ${data.token}` }
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file script.js
start_target
k6_ok script.js
expect_eq "$(stat_count 'POST /api/login 200')" "1" "logged in exactly once (in setup)"
expect_eq "$(stat_count 'GET /api/me 200')" "5" "GET /api/me succeeded on every iteration"
expect_eq "$(stat_sum ' 4[0-9][0-9]$')" "0" "no 4xx responses"

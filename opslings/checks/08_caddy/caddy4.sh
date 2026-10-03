#!/usr/bin/env bash
# REQUIRES: caddy curl jq
# HINT
# `handle` keeps the /app prefix, so the upstream sees /app/api/items and
# answers 404. Use handle_path instead:
#   handle_path /app/* {
#     reverse_proxy {$UPSTREAM}
#   }
# and make the redirect permanent:
#   redir /legacy /app/ 301
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file Caddyfile
start_target
caddy_start UPSTREAM="$TARGET_URL"
expect_eq "$(http_status "$CADDY_URL/app/api/items")" "200" "GET /app/api/items"
expect_eq "$(stat_count 'GET /api/items 200')" "1" "upstream saw /api/items (prefix stripped)"
expect_eq "$(curl -s "$CADDY_URL/app/api/items/1" | jq -r .name 2>/dev/null)" "pager" "GET /app/api/items/1 body"
expect_eq "$(http_status "$CADDY_URL/legacy")" "301" "GET /legacy status"
expect_eq "$(http_header "$CADDY_URL/legacy" Location)" "/app/" "GET /legacy Location"
expect_eq "$(http_status "$CADDY_URL/nope")" "404" "GET /nope status"
expect_eq "$(curl -s "$CADDY_URL/nope")" "not found" "GET /nope body"

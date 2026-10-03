#!/usr/bin/env bash
# REQUIRES: caddy curl jq
# HINT
# Caddy sorts directives by a fixed order, not by their position in the
# file, and `respond` sorts before `reverse_proxy`: the catch-all respond
# answers everything. Make the choice explicit with handle blocks (the
# first matching one wins, and they are sorted by path specificity):
#   header X-Served-By opslings-edge
#   header -Server
#   handle /api/* {
#     reverse_proxy {$UPSTREAM}
#   }
#   handle {
#     respond "edge ok" 200
#   }
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file Caddyfile
start_target
caddy_start UPSTREAM="$TARGET_URL"
expect_eq "$(http_status "$CADDY_URL/api/items")" "200" "GET /api/items through caddy"
expect_eq "$(stat_count 'GET /api/items 200')" "1" "upstream saw GET /api/items"
expect_eq "$(curl -s "$CADDY_URL/api/items/3" | jq -r .name 2>/dev/null)" "runbook" "GET /api/items/3 body comes from the upstream"
expect_eq "$(curl -s "$CADDY_URL/")" "edge ok" "GET / answered by caddy"
expect_eq "$(stat_count 'GET / 200')" "0" "GET / never reached the upstream"
expect_eq "$(http_header "$CADDY_URL/api/items" X-Served-By)" "opslings-edge" "X-Served-By on proxied responses"
expect_eq "$(http_header "$CADDY_URL/" X-Served-By)" "opslings-edge" "X-Served-By on caddy's own responses"
expect_eq "$(http_header "$CADDY_URL/" Server)" "" "no Server header"

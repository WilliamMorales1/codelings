#!/usr/bin/env bash
# REQUIRES: caddy curl
# HINT
# The files live in ./site, not ./public. Then:
#   @spa {
#     not path /assets/*
#     not file
#   }
#   rewrite @spa /index.html
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file Caddyfile site/index.html site/assets/app.js
caddy_start
expect_eq "$(http_status "$CADDY_URL/")" "200" "GET / status"
grep -q 'single-page app shell' <<<"$(curl -s "$CADDY_URL/")" || fail "GET / does not serve site/index.html"
ok "GET / serves index.html"
grep -q 'rendered by app.js' <<<"$(curl -s "$CADDY_URL/assets/app.js")" || fail "GET /assets/app.js does not serve the JS file"
ok "GET /assets/app.js serves the file"
expect_eq "$(http_status "$CADDY_URL/dashboard/settings")" "200" "GET /dashboard/settings status"
grep -q 'single-page app shell' <<<"$(curl -s "$CADDY_URL/dashboard/settings")" || fail "GET /dashboard/settings should fall back to index.html"
ok "GET /dashboard/settings falls back to index.html"
expect_eq "$(http_status "$CADDY_URL/assets/missing.js")" "404" "GET /assets/missing.js status"

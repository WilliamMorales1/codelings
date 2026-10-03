#!/usr/bin/env bash
# REQUIRES: caddy curl
# HINT
# The address needs the environment form:  :{$PORT} {
# and the health path is /healthz:
#   respond /healthz "ok" 200
source "$OPSLINGS_ROOT/checks/lib.sh"

need_file Caddyfile
caddy_start
expect_eq "$(curl -s "$CADDY_URL/healthz")" "ok" "GET /healthz body"
expect_eq "$(http_status "$CADDY_URL/healthz")" "200" "GET /healthz status"
expect_eq "$(curl -s "$CADDY_URL/")" "hello from caddy" "GET / body"
expect_eq "$(curl -s "$CADDY_URL/some/other/page")" "hello from caddy" "GET /some/other/page body"

#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Convert before comparing:  select((.PRIORITY | tonumber) <= 4)
source "$SYSTEMDLINGS_LIB"

u=systemdlings-mixed.service
install_units
verify_units $u
mark
start_ok $u
wait_log $u 'config reloaded' 5
got=$(unit_log_json $u | jq -r -f problems.jq 2>&1) || { echo "$got"; fail "jq failed on problems.jq"; }
want='4 slow query: 2.3s
3 upstream timed out
2 database corrupted'
if [[ "$got" != "$want" ]]; then
  echo "your filter printed:"
  echo "$got" | sed 's/^/    /'
  echo "expected:"
  echo "$want" | sed 's/^/    /'
  fail "wrong entries"
fi
ok "problems.jq picks the warnings and worse"

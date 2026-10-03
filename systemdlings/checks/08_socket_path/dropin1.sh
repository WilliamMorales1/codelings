#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Clear the list before adding to it:
#   [Service]
#   ExecStart=
#   ExecStart=/usr/bin/sh -c '...9090...'
source "$SYSTEMDLINGS_LIB"

u=systemdlings-vendor.service
orig="$SYSTEMDLINGS_ROOT/.templates/08_socket_path/dropin1/$u"
cmp -s $u "$orig" || fail "$u was edited; restore it (systemdlings reset dropin1) and use the drop-in"
ok "$u is untouched"
install_units
verify_units $u
sctl cat $u 2>/dev/null | grep -q "$u.d/override.conf" || fail "systemctl cat does not show the drop-in"
ok "systemctl --user cat $u shows override.conf"
mark
start_ok $u
wait_log $u '^listening on port 9090$' 5
if unit_log $u | grep -q 8080; then fail "the old command ran too"; fi

#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Add `SyslogIdentifier=ledger` to [Service], then try
#   journalctl --user -t ledger
source "$SYSTEMDLINGS_LIB"

u=systemdlings-ledger.service
install_units
verify_units $u
expect_prop $u SyslogIdentifier ledger
mark
start_ok $u
_t_has() { journalctl --user --after-cursor "$CURSOR" -t ledger -o cat --no-pager | grep -q "$1"; }
wait_until 5 _t_has '^balance ok$' || fail "journalctl --user -t ledger does not show 'balance ok'"
ok "journalctl -t ledger shows 'balance ok'"
wait_until 5 _t_has '^ledger run at ' || fail "journalctl --user -t ledger does not show the date line"
ok "journalctl -t ledger shows the date line, too"

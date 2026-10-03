#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Use `Type=exec`. oneshot waits for the loop to finish (it never does), and
# simple would also run the ticker but reports success even for an
# ExecStart= binary that does not exist.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-ticker.service
install_units
verify_units $u
mark
start_ok $u 8
expect_eq "$(prop $u ActiveState)/$(prop $u SubState)" "active/running" "$u is running after start returned"
wait_log $u '^tick$' 5
sctl stop $u

# Same unit, broken binary: start itself has to report the failure.
mkdir -p "$UNIT_DIR/$u.d"
printf '[Service]\nExecStart=\nExecStart=/usr/bin/systemdlings-no-such-binary\n' >"$UNIT_DIR/$u.d/50-typo.conf"
sctl daemon-reload
if start $u 8; then
  fail "with a missing ExecStart= binary, systemctl start still reported success (Type=$(prop $u Type))"
fi
ok "a missing binary makes systemctl start fail"

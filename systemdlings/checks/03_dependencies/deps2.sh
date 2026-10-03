#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Replace `Wants=` with `Requires=` and keep `After=`. Without After=,
# Requires= starts both at once and cannot hold the indexer back.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-indexer.service
install_units
verify_units systemdlings-mount.service $u
expect_match "$(prop $u Requires)" 'systemdlings-mount\.service' "indexer Requires= the mount"
expect_match "$(prop $u After)" 'systemdlings-mount\.service' "indexer is ordered After= the mount"
track systemdlings-mount.service
mark
if start $u; then
  fail "$u started although the mount failed"
fi
echo "$START_OUT" | sed 's/^/    /'
ok "start of the indexer fails"
if unit_log $u | grep -q 'writing index'; then
  fail "the indexer ran and wrote to the root filesystem"
fi
ok "the indexer never ran"

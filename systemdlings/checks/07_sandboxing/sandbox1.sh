#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Add `ReadWritePaths=%t/systemdlings/sandbox1/state` to [Service].
# Opening all of %t would work too, but the task asks for the state dir only.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-counter.service
install_units
verify_units $u
expect_prop $u ProtectSystem strict
expect_eq "$(prop $u ReadWritePaths)" "$DATA/state" "ReadWritePaths is exactly the state directory"
mark
start_ok $u
start_ok $u
wait_log $u '^run number 2$' 5
expect_eq "$(cat "$DATA/state/count")" 2 "state/count"

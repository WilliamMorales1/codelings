#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# In [Service]:
#   Restart=on-failure
#   RestartSec=500ms
# `always` would also restart a clean exit, which the task rules out.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-flaky.service
install_units
verify_units $u
expect_prop $u Restart on-failure
expect_prop $u RestartUSec 500ms
mark
start_ok $u
wait_log $u 'attempt 3: connected' 8
expect_eq "$(prop $u ActiveState)/$(prop $u SubState)" "active/running" "$u ends up running"
expect_prop $u NRestarts 2

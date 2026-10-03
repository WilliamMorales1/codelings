#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Add `SuccessExitStatus=3` to [Service]. Do not use a "-" prefix on
# ExecStart=: that would hide real errors too.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-sync.service
install_units
verify_units $u
mark
start_ok $u
expect_prop $u Result success
wait_log $u 'nothing to sync'
echo 4 >"$(data exit-code)"
if start $u; then
  fail "exit code 4 is a real error, but the start still succeeded"
fi
expect_prop $u Result exit-code

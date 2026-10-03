#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Add `PrivateNetwork=yes` to [Service].
source "$SYSTEMDLINGS_LIB"

u=systemdlings-offline.service
install_units
verify_units $u
mark
start_ok $u
wait_log $u '^interfaces: ' 5
line=$(unit_log $u | grep '^interfaces: ' | tail -1)
expect_eq "$(echo $line)" "interfaces: lo" "interfaces visible to the job"
expect_prop $u PrivateNetwork yes

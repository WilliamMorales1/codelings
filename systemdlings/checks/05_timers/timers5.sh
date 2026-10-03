#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Add `OnUnitActiveSec=2s` next to OnActiveSec=1s.
source "$SYSTEMDLINGS_LIB"

t=systemdlings-heartbeat.timer
install_units
verify_units $t
track systemdlings-heartbeat.service
mark
start_ok $t
sleep 6
n=$(unit_log systemdlings-heartbeat.service | grep -c '^heartbeat$')
((n >= 3 && n <= 4)) || fail "expected 3 heartbeats in 6 seconds (at 1s, 3s, 5s), got $n"
ok "$n heartbeats in 6 seconds"
expect_prop $t ActiveState active

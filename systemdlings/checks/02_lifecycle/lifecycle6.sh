#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Add `KillSignal=SIGINT` to [Service]. Leave TimeoutStopSec= alone; it is
# the safety net for when the clean shutdown hangs.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-queue.service
install_units
verify_units $u
mark
start_ok $u
wait_log $u '^consuming$' 5
sctl stop $u
wait_log $u '^flushing queue$' 3
expect_eq "$(cat "$(data state)")" flushed "queue state after stop"
expect_prop $u Result success

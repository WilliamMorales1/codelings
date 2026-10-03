#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Prefix the lines with the level number in angle brackets:
#   echo "<4>disk almost full (93%)"
#   echo "<3>backup failed: no space left on device"
# The "WARNING:"/"ERROR:" words become redundant; drop them if you like.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-backup-log.service
install_units
verify_units $u
mark
start_ok $u
wait_log $u 'backup failed' 5
prio() { unit_log_json $u | jq -r --arg m "$1" 'select(.MESSAGE | test($m)) | .PRIORITY' | head -1; }
expect_eq "$(prio 'starting backup')" 6 "priority of 'starting backup'"
expect_eq "$(prio 'disk almost full')" 4 "priority of 'disk almost full'"
expect_eq "$(prio 'backup failed')" 3 "priority of 'backup failed'"
if unit_log $u | grep -q '^<'; then
  fail "a '<N>' prefix ended up in the message; it must be the very first thing on the line"
fi

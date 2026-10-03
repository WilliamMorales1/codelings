#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Add `WorkingDirectory=%t/systemdlings/env3` to [Service] and keep
# `ExecStart=/usr/bin/cat motd.txt` as it is.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-motd.service
install_units
verify_units $u
grep -q '^ExecStart=/usr/bin/cat motd.txt$' "$UNIT_DIR/$u" || fail "keep ExecStart=/usr/bin/cat motd.txt (relative path) and fix the directory instead"
mark
start_ok $u
wait_log $u 'learn WorkingDirectory' 3
expect_prop $u WorkingDirectory "$DATA"

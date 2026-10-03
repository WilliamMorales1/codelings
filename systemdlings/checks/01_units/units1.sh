#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Type= and ExecStart= are [Service] keys, but the file never opens a
# [Service] section, so they land in [Unit]. Add a `[Service]` header line
# above them. `systemd-analyze verify --user FILE` shows the warning.
source "$SYSTEMDLINGS_LIB"

install_units
verify_units systemdlings-backup.service
expect_prop systemdlings-backup.service Type oneshot
mark
start_ok systemdlings-backup.service
wait_log systemdlings-backup.service '^backup finished$'

#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Keep `After=systemdlings-db.service` (wait for it) and add
# `Wants=systemdlings-db.service` (pull it in). Check with
#   systemctl --user list-dependencies systemdlings-app.service
source "$SYSTEMDLINGS_LIB"

install_units
verify_units systemdlings-db.service systemdlings-app.service
expect_match "$(prop systemdlings-app.service Wants)" 'systemdlings-db\.service' "app Wants= the database"
expect_match "$(prop systemdlings-app.service After)" 'systemdlings-db\.service' "app is ordered After= the database"
track systemdlings-db.service
mark
start_ok systemdlings-app.service
expect_prop systemdlings-db.service ActiveState active
wait_log systemdlings-app.service 'database is ready'

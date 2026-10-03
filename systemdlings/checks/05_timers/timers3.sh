#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Add `Unit=systemdlings-reporter.service` to the [Timer] section.
source "$SYSTEMDLINGS_LIB"

t=systemdlings-report.timer
install_units
verify_units $t
expect_prop $t Triggers systemdlings-reporter.service
track systemdlings-reporter.service
mark
start_ok $t
wait_log systemdlings-reporter.service '^report generated$' 5

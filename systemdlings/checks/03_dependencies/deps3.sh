#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze
# HINT
# One line in [Unit] does it; Wants= takes a space-separated list:
#   Wants=systemdlings-api.service systemdlings-worker.service
# (The other way round, WantedBy=systemdlings-stack.target in the services'
# [Install] sections, would need `systemctl enable` first.)
source "$SYSTEMDLINGS_LIB"

install_units
verify_units systemdlings-stack.target
track systemdlings-api.service
track systemdlings-worker.service
start_ok systemdlings-stack.target
wait_state systemdlings-api.service active 3
wait_state systemdlings-worker.service active 3
sctl list-dependencies --plain systemdlings-stack.target 2>&1 | head -4 | sed 's/^/    /'

#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# `ProtectHome=yes`. read-only still allows reading, and tmpfs leaves an
# empty, listable directory behind.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-thumbnailer.service
install_units
verify_units $u
expect_prop $u ProtectHome yes
mark
start_ok $u
wait_log $u '^home is hidden$' 5

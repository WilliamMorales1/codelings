#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# ExecStart=/usr/bin/echo "hello %i"
# (You can use %i in Description= too: `systemctl list-units` gets nicer.)
source "$SYSTEMDLINGS_LIB"

install_units
verify_units systemdlings-greet@alice.service
mark
for who in alice bob; do
  start_ok systemdlings-greet@$who.service
done
for who in alice bob; do
  wait_log systemdlings-greet@$who.service "^hello $who\$" 3
done

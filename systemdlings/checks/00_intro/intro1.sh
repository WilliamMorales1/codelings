#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Make ExecStart in exercises/00_intro/intro1/systemdlings-hello.service
# echo exactly `hello from systemdlings`, then save.
source "$SYSTEMDLINGS_LIB"

install_units
verify_units systemdlings-hello.service
mark
start_ok systemdlings-hello.service
wait_log systemdlings-hello.service '^hello from systemdlings$'

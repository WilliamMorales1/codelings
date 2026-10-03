#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Quote the whole assignment and add the second variable:
#   Environment="GREETING=hello world" TARGET=systemd
# (Two separate Environment= lines work too.)
source "$SYSTEMDLINGS_LIB"

u=systemdlings-greeter.service
install_units
verify_units $u
env=$(prop $u Environment)
echo "    Environment: $env"
mark
start_ok $u
wait_log $u '^hello world, systemd$'

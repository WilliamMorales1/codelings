#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# EnvironmentFile=%t/systemdlings/env2/app.env
# and delete the word `export` from every line of app.env.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-envapp.service
install_units
verify_units $u
mark
start_ok $u
wait_log $u '^listening on 8080 in production mode$' 3

#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze
# HINT
# Both keys go in [Unit], not [Service]:
#   StartLimitIntervalSec=30s
#   StartLimitBurst=3
source "$SYSTEMDLINGS_LIB"

u=systemdlings-crashloop.service
install_units
verify_units $u
expect_prop $u StartLimitBurst 3
expect_prop $u StartLimitIntervalUSec 30s
start $u
wait_state $u failed 6
expect_prop $u Result start-limit-hit
n=$(prop $u NRestarts); ((n >= 2 && n <= 3)) || fail "expected systemd to give up after 3 starts, NRestarts=$n"; ok "gave up after NRestarts=$n"

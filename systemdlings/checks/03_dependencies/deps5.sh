#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze
# HINT
# Replace `Requires=` with `BindsTo=` and keep `After=`.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-vpn-sync.service
install_units
verify_units systemdlings-vpn.service $u
track systemdlings-vpn.service
start_ok $u
expect_prop systemdlings-vpn.service ActiveState active
expect_prop $u ActiveState active
wait_until 6 _state_is systemdlings-vpn.service failed || fail "the pretend VPN should have dropped by now"
ok "the VPN dropped"
wait_state $u inactive 3

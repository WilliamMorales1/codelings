#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze
# HINT
# Add `PartOf=systemdlings-shop.target` to the mailer's [Unit] section.
source "$SYSTEMDLINGS_LIB"

install_units
verify_units systemdlings-shop.target systemdlings-shop-mailer.service
track systemdlings-shop-web.service
track systemdlings-shop-mailer.service
start_ok systemdlings-shop.target
wait_state systemdlings-shop-mailer.service active 3
pid=$(prop systemdlings-shop-mailer.service MainPID)
sctl restart systemdlings-shop.target
wait_state systemdlings-shop-mailer.service active 3
[[ "$(prop systemdlings-shop-mailer.service MainPID)" != "$pid" ]] ||
  fail "restarting the target did not restart the mailer (same PID $pid)"
ok "restarting the target restarts the mailer"
sctl stop systemdlings-shop.target
wait_state systemdlings-shop-web.service inactive 3
wait_state systemdlings-shop-mailer.service inactive 3

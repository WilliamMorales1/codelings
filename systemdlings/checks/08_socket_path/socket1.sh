#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze
# HINT
# Add `StandardInput=socket` to the [Service] section of
# systemdlings-hello@.service. Test by hand with
#   bash -c 'exec 3<>/dev/tcp/127.0.0.1/47811; echo you >&3; cat <&3'
source "$SYSTEMDLINGS_LIB"

port_free 47811
install_units
verify_units systemdlings-hello.socket
start_ok systemdlings-hello.socket
expect_prop systemdlings-hello.socket SubState listening
for who in ada linus; do
  expect_eq "$(ask 47811 $who)" "hello $who" "reply to $who"
done
expect_match "$(prop systemdlings-hello.socket NAccepted)" '^[2-9]' "the socket accepted the connections"

#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Add `PrivateTmp=yes` to [Service].
source "$SYSTEMDLINGS_LIB"

u=systemdlings-converter.service
leak=/tmp/systemdlings-sandbox3-intermediate.txt
on_exit "rm -f $leak"
rm -f $leak
install_units
verify_units $u
mark
start_ok $u
wait_log $u 'wrote intermediate file' 5
[[ ! -e $leak ]] || fail "$leak is on the shared /tmp for everyone to read"
ok "the intermediate file stayed private"
expect_prop $u PrivateTmp yes

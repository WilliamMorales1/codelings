#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze
# HINT
# Add `RemainAfterExit=yes` to the [Service] section. Without it a oneshot
# unit is "inactive" again as soon as ExecStart= is done, and systemd runs
# ExecStop= right away because the unit is considered stopped.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-scratch.service
install_units
verify_units $u
start_ok $u
expect_eq "$(prop $u ActiveState)/$(prop $u SubState)" "active/exited" "$u stays active after ExecStart= finished"
[[ -d $(data scratch) ]] || fail "the scratch directory is gone while the unit is still meant to be up"
ok "scratch directory exists while the unit is active"
sctl stop $u || fail "systemctl --user stop $u failed"
[[ ! -e $(data scratch) ]] || fail "stopping the unit should have removed the scratch directory"
ok "stop removed the scratch directory"

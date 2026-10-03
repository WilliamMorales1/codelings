#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze
# HINT
# Change `ExecStop=` to `ExecStopPost=`. ExecStop= is skipped when the main
# process dies by itself; ExecStopPost= always runs.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-worker.service
lock=$(data worker.lock)
install_units
verify_units $u
start_ok $u
[[ -e $lock ]] || fail "the lock file should exist while the worker runs"
ok "lock taken while running"
wait_state $u failed 6
expect_prop $u ExecMainStatus 139
[[ ! -e $lock ]] || fail "the worker crashed and left $lock behind"
ok "lock removed after the crash"

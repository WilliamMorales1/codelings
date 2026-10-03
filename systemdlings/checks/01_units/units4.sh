#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze
# HINT
# `systemd-notify` runs as a child of the shell, not as the main process.
# Add `NotifyAccess=all` to [Service] so systemd accepts READY=1 from any
# process in the unit. Keep Type=notify.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-warmup.service
install_units
verify_units $u
expect_prop $u Type notify
begin=$(date +%s%N)
start_ok $u 8
took=$((($(date +%s%N) - begin) / 1000000))
((took >= 900)) || fail "start returned after ${took}ms, before the service could have said READY=1"
ok "start waited for READY=1 (${took}ms)"
expect_eq "$(prop $u ActiveState)/$(prop $u SubState)" "active/running" "$u is running"
expect_prop $u StatusText serving

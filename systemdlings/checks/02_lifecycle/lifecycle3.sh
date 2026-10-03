#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Drop the "-" right after `ExecStartPre=`. With it, the failing `test -f`
# is ignored and `cat` runs anyway (and fails on its own, with a less useful
# error, or worse: succeeds on a stale file).
source "$SYSTEMDLINGS_LIB"

u=systemdlings-webapp.service
install_units
verify_units $u
rm -f "$(data app.conf)"
mark
if start $u; then
  fail "$u started without app.conf"
fi
ok "start fails without app.conf"
expect_prop $u ExecMainPID 0
if unit_log $u | grep -q 'No such file'; then
  fail "ExecStart= ran even though the pre-check failed"
fi
ok "ExecStart= never ran"
cp "$(data app.conf.example)" "$(data app.conf)"
sctl reset-failed $u
mark
start_ok $u
wait_log $u 'hello from the config'

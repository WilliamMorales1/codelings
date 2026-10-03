#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
#   MemoryMax=64M
#   MemorySwapMax=0
#   CPUQuota=50%
# MemoryHigh= only throttles; you can keep it or drop it.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-hog.service
install_units
verify_units $u
expect_prop $u MemoryMax $((64 * 1024 * 1024))
expect_prop $u MemorySwapMax 0
expect_prop $u CPUQuotaPerSecUSec 500ms
ctl=/sys/fs/cgroup/user.slice/user-$(id -u).slice/user@$(id -u).service/cgroup.controllers
if [[ -r $ctl ]] && ! grep -qw memory "$ctl"; then
  fail "the memory controller is not delegated to your user manager ($ctl), so MemoryMax= cannot work here"
fi
mark
if start $u 30; then
  fail "the hog finished; it should have been killed at 64M"
fi
expect_prop $u Result oom-kill
if unit_log $u | grep -q 'survived'; then
  fail "the hog survived"
fi
ok "the hog was OOM-killed inside its own cgroup"

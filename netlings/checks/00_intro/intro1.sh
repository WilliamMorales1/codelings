#!/usr/bin/env bash
# REQUIRES: ip ping jq unshare
# HINT
# `ip link set DEV up` brings an interface up; the line in
# exercises/00_intro/intro1/setup.sh does the opposite.
source "$NETLINGS_ROOT/checks/lib.sh"
sandbox
sandbox_here "lo is still DOWN here. Run 'bash setup.sh' to apply the exercise."

run_setup
flags=$(ip -j link show lo | jq -c '.[0].flags')
[[ $flags == *'"UP"'* ]] || fail "lo is not UP (flags: $flags)"
ok "lo is UP"
expect_ping - 127.0.0.1 "ping 127.0.0.1 answers"

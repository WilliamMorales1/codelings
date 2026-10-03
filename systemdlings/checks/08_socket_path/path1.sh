#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Watch for content, not for existence:
#   DirectoryNotEmpty=%t/systemdlings/path1/inbox
source "$SYSTEMDLINGS_LIB"

p=systemdlings-inbox.path
s=systemdlings-inbox.service
install_units
verify_units $p
track $s
mark
mkdir -p "$DATA/inbox"
start_ok $p
sleep 1.5
if unit_log $s | grep -q 'processing inbox'; then
  fail "the processor ran while the inbox was empty"
fi
expect_prop $p ActiveState active
ok "nothing happens while the inbox is empty"
echo "q3 numbers" >"$DATA/inbox/report.txt"
wait_log $s '^processed report.txt$' 5
[[ -f "$DATA/done/report.txt" ]] || fail "report.txt did not end up in done/"
ok "report.txt moved to done/"
echo "more" >"$DATA/inbox/second.txt"
wait_log $s '^processed second.txt$' 5
expect_prop $p ActiveState active

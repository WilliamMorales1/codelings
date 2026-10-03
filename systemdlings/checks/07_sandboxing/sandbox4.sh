#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Start with the list in the file header; that alone gets close to 2.6.
# Run the offline scorer after every few lines to watch the number drop:
#   systemd-analyze security --offline=true --user systemdlings-parser.service | tail -1
# If the service then fails to start, check `journalctl --user -u ...` for
# the setting that broke it.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-parser.service
score_out=$(systemd-analyze security --offline=true --user --no-pager $u 2>&1)
line=$(grep 'Overall exposure level' <<<"$score_out")
[[ -n "$line" ]] || { echo "$score_out" | tail -5; fail "systemd-analyze security could not score $u"; }
echo "    $line"
score=$(grep -oE '[0-9]+\.[0-9]+' <<<"$line" | head -1)
awk -v s="$score" 'BEGIN { exit !(s <= 3.0) }' || fail "exposure $score is above 3.0"
ok "exposure $score <= 3.0"
install_units
verify_units $u
mark
start_ok $u
wait_log $u '^parsed 3 records$' 5

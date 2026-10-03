#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
#   StandardOutput=truncate:%t/systemdlings/journal4/report.csv
#   StandardError=journal
# StandardError= must be set explicitly: it inherits stdout's destination.
source "$SYSTEMDLINGS_LIB"

u=systemdlings-report-csv.service
csv=$(data report.csv)
install_units
verify_units $u
printf 'stale,data\n' >"$csv"
mark
start_ok $u
start_ok $u
want='day,orders
mon,12
tue,17'
expect_eq "$(cat "$csv" 2>/dev/null)" "$want" "report.csv after two runs"
wait_log $u 'orders skipped' 5
if unit_log $u | grep -q 'mon,12'; then
  fail "the CSV lines still end up in the journal"
fi
ok "only diagnostics in the journal"

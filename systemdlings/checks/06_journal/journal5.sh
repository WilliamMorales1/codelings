#!/usr/bin/env bash
# REQUIRES: systemd-cat journalctl jq
# HINT
# systemd-cat -t systemdlings-nightly --stderr-priority=err sh job.sh
# (-p sets stdout's priority; its default, info, is already right.)
source "$SYSTEMDLINGS_LIB"

need_file run.sh job.sh
mark
out=$(timeout 10 bash run.sh 2>&1) || { echo "$out"; fail "run.sh failed"; }
[[ -z "$out" ]] || { echo "$out" | sed 's/^/    /'; fail "run.sh printed to the terminal; its output should go to the journal"; }
_entries() { journalctl --user --after-cursor "$CURSOR" -t systemdlings-nightly -o json --no-pager | jq -r '"\(.PRIORITY) \(.MESSAGE)"'; }
_has() { _entries | grep -qF "$1"; }
wait_until 5 _has "6 exported 3 tables" || { _entries | sed 's/^/    /'; fail "no info entry 'exported 3 tables' with identifier systemdlings-nightly"; }
ok "stdout logged at info"
wait_until 3 _has "3 table 'audit' is empty, skipped" || { _entries | sed 's/^/    /'; fail "no err entry for the stderr line"; }
ok "stderr logged at err"

#!/usr/bin/env bash
# REQUIRES: systemd-analyze
# HINT
# Day-of-week range first, then the time:
#   OnCalendar=Mon..Fri 09:30
# Check it with: systemd-analyze calendar --iterations=5 'Mon..Fri 09:30'
source "$SYSTEMDLINGS_LIB"

t=systemdlings-standup.timer
need_file $t
mapfile -t specs < <(calendar_specs $t)
((${#specs[@]} > 0)) || fail "no OnCalendar= line in $t"
got=$(next_elapses 6 '2026-10-02 12:00:00 UTC' "${specs[@]}")
want='Mon 2026-10-05 09:30:00
Tue 2026-10-06 09:30:00
Wed 2026-10-07 09:30:00
Thu 2026-10-08 09:30:00
Fri 2026-10-09 09:30:00
Mon 2026-10-12 09:30:00'
if [[ "$got" != "$want" ]]; then
  echo "after Fri 2026-10-02 12:00 your timer fires at:"
  echo "$got" | sed 's/^/    /'
  echo "but it should fire at:"
  echo "$want" | sed 's/^/    /'
  fail "wrong schedule"
fi
ok "fires weekdays at 09:30 and nothing else"

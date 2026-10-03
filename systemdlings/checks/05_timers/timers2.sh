#!/usr/bin/env bash
# REQUIRES: systemd-analyze
# HINT
#   OnCalendar=Mon *-*-01..07 03:00   (first Monday: a Monday within days 1-7)
#   OnCalendar=*-*~01 23:00           (last day of the month, counted with ~)
source "$SYSTEMDLINGS_LIB"

t=systemdlings-maintenance.timer
need_file $t
mapfile -t specs < <(calendar_specs $t)
((${#specs[@]} > 0)) || fail "no OnCalendar= line in $t"
got=$(next_elapses 8 '2026-10-02 12:00:00 UTC' "${specs[@]}")
want='Mon 2026-10-05 03:00:00
Sat 2026-10-31 23:00:00
Mon 2026-11-02 03:00:00
Mon 2026-11-30 23:00:00
Mon 2026-12-07 03:00:00
Thu 2026-12-31 23:00:00
Mon 2027-01-04 03:00:00
Sun 2027-01-31 23:00:00'
if [[ "$got" != "$want" ]]; then
  echo "after Fri 2026-10-02 12:00 your timer fires at:"
  echo "$got" | sed 's/^/    /'
  echo "but it should fire at:"
  echo "$want" | sed 's/^/    /'
  fail "wrong schedule"
fi
ok "first Monday 03:00 and last day of the month 23:00"
got=$(next_elapses 2 '2027-02-20 00:00:00 UTC' "${specs[@]}")
expect_eq "$(head -1 <<<"$got")" "Sun 2027-02-28 23:00:00" "February's last day"

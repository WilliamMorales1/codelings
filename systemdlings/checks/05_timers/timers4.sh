#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze
# HINT
# In [Timer]:
#   Persistent=true
#   RandomizedDelaySec=30min
# The check only loads the timer and reads its properties; it never starts it.
source "$SYSTEMDLINGS_LIB"

t=systemdlings-backup-nightly.timer
install_units
verify_units $t
expect_prop $t Persistent yes
expect_prop $t RandomizedDelayUSec 30min
expect_match "$(prop $t TimersCalendar)" 'OnCalendar=\*-\*-\* 00:00:00' "still runs daily"

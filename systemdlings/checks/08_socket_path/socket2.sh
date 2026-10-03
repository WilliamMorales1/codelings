#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze
# HINT
# With Accept=yes the socket needs a template:
#   mv systemdlings-clock.service systemdlings-clock@.service
# (Or keep one long-running service and Accept=no - but `date` cannot
# accept() connections itself, so the template is the answer here.)
source "$SYSTEMDLINGS_LIB"

port_free 47812
[[ -f systemdlings-clock@.service ]] || fail "there is no service template the socket could start"
install_units
verify_units systemdlings-clock.socket
start_ok systemdlings-clock.socket
expect_eq "$(ask 47812 '')" "$(date -u +%Y)" "the clock answers with the year"
expect_eq "$(ask 47812 '')" "$(date -u +%Y)" "and again for a second client"

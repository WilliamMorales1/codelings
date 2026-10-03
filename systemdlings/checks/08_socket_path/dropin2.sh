#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze journalctl jq
# HINT
# Rename the file so it sorts after 50-defaults.conf, e.g.
#   mv systemdlings-api.service.d/10-debug.conf systemdlings-api.service.d/90-debug.conf
source "$SYSTEMDLINGS_LIB"

u=systemdlings-api.service
d=$u.d
cmp -s $d/50-defaults.conf "$SYSTEMDLINGS_ROOT/.templates/08_socket_path/dropin2/$d/50-defaults.conf" ||
  fail "50-defaults.conf was edited; leave it alone and make your own drop-in win"
ok "50-defaults.conf is untouched"
install_units
verify_units $u
expect_match "$(prop $u Environment)" '(^| )LOG_LEVEL=debug( |$)' "LOG_LEVEL in the merged environment"
mark
start_ok $u
wait_log $u '^log level: debug$' 5

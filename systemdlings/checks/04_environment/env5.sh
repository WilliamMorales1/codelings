#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-analyze systemd-escape journalctl jq
# HINT
# %i is still escaped ("run-user-..."), %I loses the leading slash
# ("run/user/..."), %f gives "/run/user/...". Use
#   ExecStart=/usr/bin/du -s %f
source "$SYSTEMDLINGS_LIB"

install_units
u="systemdlings-du@$(systemd-escape --path "$DATA/photos").service"
echo "    instance: $u"
verify_units systemdlings-du@.service
mark
start_ok "$u"
wait_log "$u" "[[:space:]]$DATA/photos\$" 3

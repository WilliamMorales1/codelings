#!/usr/bin/env bash
# REQUIRES: systemctl systemd-analyze
# HINT
# The login target of the user manager is `default.target`:
#   [Install]
#   WantedBy=default.target
# (graphical-session.target also works for GUI helpers, but it is only
# active inside a graphical session; this check wants default.target.)
source "$SYSTEMDLINGS_LIB"

u=systemdlings-syncd.service
need_file $u
root=$(mktemp -d "${TMPDIR:-/tmp}/systemdlings-root-XXXXXX")
on_exit "rm -rf '$root'"
mkdir -p "$root/etc/systemd/user" "$root/usr/lib/systemd/user"
# The real user targets, so enable can complain about ones that do not exist.
cp -a /usr/lib/systemd/user/*.target "$root/usr/lib/systemd/user/" 2>/dev/null
cp $u "$root/etc/systemd/user/"
out=$(systemctl --global --root="$root" enable $u 2>&1) || { echo "$out"; fail "enable failed"; }
echo "$out" | sed 's/^/    /'
[[ -L "$root/etc/systemd/user/default.target.wants/$u" ]] ||
  fail "enable did not link $u into default.target.wants/"
ok "enable links $u into default.target.wants/"
others=$(find "$root/etc/systemd/user" -mindepth 2 -name "$u" -not -path '*/default.target.wants/*')
[[ -z "$others" ]] || fail "enable also created: $others"
ok "no links into targets the user manager does not have"

#!/usr/bin/env bash
# REQUIRES: user-manager systemctl systemd-run journalctl jq
# HINT
# systemd-run --user --on-active=2s --timer-property=AccuracySec=100ms \
#     --unit=systemdlings-remind /usr/bin/echo "stand up and stretch"
# With a timer option, --unit=NAME creates NAME.timer and NAME.service.
source "$SYSTEMDLINGS_LIB"

need_file remind.sh
track systemdlings-remind.timer
track systemdlings-remind.service
# A guard in front of the real systemd-run: user manager only, and only our unit name.
shim=$(mktemp -d "${TMPDIR:-/tmp}/systemdlings-shim-XXXXXX")
on_exit "rm -rf '$shim'"
real=$(command -v systemd-run)
cat >"$shim/systemd-run" <<SHIM
#!/usr/bin/env bash
user=0 unit=0
for a in "\$@"; do
  [[ "\$a" == --user ]] && user=1
  [[ "\$a" == --unit=systemdlings-remind || "\$a" == --unit=systemdlings-remind.* ]] && unit=1
done
((user)) || { echo "systemdlings: refusing systemd-run without --user" >&2; exit 1; }
((unit)) || { echo "systemdlings: pass --unit=systemdlings-remind" >&2; exit 1; }
exec "$real" "\$@"
SHIM
chmod +x "$shim/systemd-run"
mark
out=$(PATH="$shim:$PATH" timeout 10 bash remind.sh 2>&1) || { echo "$out"; fail "remind.sh failed"; }
echo "$out" | sed 's/^/    /'
expect_prop systemdlings-remind.timer LoadState loaded
expect_match "$(prop systemdlings-remind.timer AccuracyUSec)" '^100ms$' "timer AccuracySec"
# A transient echo exits so fast that journald may not tie its line to the unit;
# the message is unique, so look for it anywhere in the user journal.
_said() { journalctl --user --after-cursor "$CURSOR" -o cat --no-pager | grep -qx 'stand up and stretch'; }
sleep 0.8
if _said; then
  fail "the reminder fired right away instead of after 2 seconds"
fi
ok "nothing yet after 0.8s"
wait_until 5 _said || fail "no 'stand up and stretch' in the journal within 5 seconds"
ok "the reminder fired"

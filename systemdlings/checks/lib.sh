# Shared helpers for systemdlings checks. Source it first thing:
#   source "$SYSTEMDLINGS_LIB"
# The check runs with cwd = the exercise directory; exit 0 means pass.
#
# Safety rules every check follows through these helpers:
#   - only unit files named systemdlings-* are installed, and only into
#     $XDG_RUNTIME_DIR/systemd/user (tmpfs, part of the user manager's search path);
#   - only `systemctl --user` is ever called, never the system manager;
#   - everything installed or started is stopped and removed again on exit.

set -uo pipefail

: "${SYSTEMDLINGS_ROOT:?run checks through systemdlings}"
: "${EXERCISE_NAME:?run checks through systemdlings}"

export SYSTEMD_PAGER="" SYSTEMD_COLORS=0 SYSTEMD_LESS=""
RT="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
UNIT_DIR="$RT/systemd/user"
# DATA is where the exercise directory is copied, i.e. %t/systemdlings/<exercise> inside a unit.
DATA="$RT/systemdlings/$EXERCISE_NAME"
OWNED="$RT/systemdlings/.owned/$EXERCISE_NAME"

_stop=()
_files=()
_cleanup_cmds=()
_reload=0

sctl() { systemctl --user "$@"; }

_cleanup() {
  local c f
  trap - EXIT TERM INT
  for c in "${_cleanup_cmds[@]}"; do eval "$c" >/dev/null 2>&1; done
  if ((${#_stop[@]})); then
    sctl stop "${_stop[@]}" >/dev/null 2>&1
    sctl reset-failed "${_stop[@]}" >/dev/null 2>&1
  fi
  for f in "${_files[@]}"; do rm -rf -- "${UNIT_DIR:?}/$f"; done
  ((_reload)) && sctl daemon-reload >/dev/null 2>&1
  rm -rf -- "${DATA:?}" "${OWNED:?}"
}
trap _cleanup EXIT
trap 'exit 143' TERM INT

# on_exit CMD: run CMD (a string) when the check ends, pass or fail.
on_exit() { _cleanup_cmds+=("$1"); }

fail() {
  echo "FAIL: $*"
  exit 1
}

ok() { echo "ok: $*"; }

# expect_eq ACTUAL EXPECTED WHAT
expect_eq() {
  [[ "$1" == "$2" ]] || fail "$3: expected '$2', got '$1'"
  ok "$3"
}

# expect_match ACTUAL REGEX WHAT
expect_match() {
  [[ "$1" =~ $2 ]] || fail "$3: '$1' does not match /$2/"
  ok "$3"
}

need_file() {
  local f
  for f in "$@"; do
    [[ -e "$f" ]] || fail "missing $f"
  done
}

_guard() {
  [[ "$1" =~ ^systemdlings-[A-Za-z0-9@._:*\\-]+$ ]] ||
    fail "refusing to touch '$1': every unit in this course must be named systemdlings-*"
}

# track UNIT_OR_PATTERN: stop (and reset-failed) it when the check ends.
track() {
  _guard "$1"
  _stop+=("$1")
  mkdir -p "${OWNED%/*}" && echo "stop $1" >>"$OWNED"
}

_own_file() {
  _files+=("$1")
  mkdir -p "${OWNED%/*}" && echo "file $1" >>"$OWNED"
}

_is_unit_file() { [[ "$1" =~ \.(service|socket|timer|path|target|slice)$ ]]; }

# install_units: copy the exercise to $DATA and every systemdlings-* unit file
# (plus *.d drop-in directories) into the runtime unit directory, then daemon-reload.
# Services that set no SyslogIdentifier= get one (%N) through a drop-in, so their
# output can be found in the journal even when it comes from short-lived children.
install_units() {
  local f name frag
  rm -rf -- "${DATA:?}"
  mkdir -p "$DATA" "$UNIT_DIR"
  cp -a . "$DATA/" || fail "cannot copy the exercise to $DATA"
  for f in *; do
    name=${f%/}
    if [[ -d "$f" && "$name" == *.d ]]; then
      _is_unit_file "${name%.d}" || continue
    elif ! _is_unit_file "$name"; then
      continue
    fi
    _guard "$name"
    if [[ ! -d "$f" && "$name" != *@.* ]]; then
      frag=$(sctl show -p FragmentPath --value "$name" 2>/dev/null)
      if [[ -n "$frag" && "$frag" != "$UNIT_DIR/"* ]]; then
        fail "a unit called $name already exists at $frag; not touching it"
      fi
    fi
    _own_file "$name"
    rm -rf -- "${UNIT_DIR:?}/$name"
    cp -a "$f" "$UNIT_DIR/$name"
    if [[ -f "$f" ]]; then
      if [[ "$name" == *@.* ]]; then
        track "${name%%@*}@*.${name##*.}"
      else
        track "$name"
      fi
      if [[ "$name" == *.service && -z "${SDL_NO_IDENT:-}" ]] && ! grep -q '^[[:space:]]*SyslogIdentifier=' "$f"; then
        _own_file "$name.d"
        mkdir -p "$UNIT_DIR/$name.d"
        printf '[Service]\nSyslogIdentifier=%%N\n' >"$UNIT_DIR/$name.d/99-systemdlings-ident.conf"
      fi
    fi
  done
  ((${#_files[@]})) || fail "no systemdlings-* unit files found in the exercise"
  _reload=1
  sctl daemon-reload || fail "daemon-reload failed"
}

# verify_units UNIT...: systemd-analyze verify must accept the installed units without a single warning.
verify_units() {
  local u out paths=()
  for u in "$@"; do paths+=("$UNIT_DIR/$u"); done
  out=$(systemd-analyze verify --user "${paths[@]}" 2>&1)
  local rc=$?
  # Complaints about units outside this course (a broken unit elsewhere on the box) are not the learner's problem.
  out=$(grep -E 'systemdlings' <<<"$out")
  if ((rc != 0)) || [[ -n "$out" ]]; then
    echo "$out"
    fail "systemd-analyze verify complains about $*"
  fi
  ok "systemd-analyze verify accepts $*"
}

# prop UNIT PROPERTY: print one property as systemctl --user show sees it.
prop() { sctl show -p "$2" --value "$1" 2>/dev/null; }

# expect_prop UNIT PROPERTY EXPECTED
expect_prop() { expect_eq "$(prop "$1" "$2")" "$3" "$1 $2"; }

# start UNIT [SECONDS]: systemctl --user start, bounded; the unit is tracked for cleanup.
start() {
  local u=$1 secs=${2:-20}
  _guard "$u"
  track "$u"
  START_OUT=$(timeout "$secs" systemctl --user start "$u" 2>&1)
}

# start_ok UNIT [SECONDS]
start_ok() {
  start "$@" || {
    echo "$START_OUT"
    sctl status --no-pager -n 8 "$1" 2>&1 | sed 's/^/  /'
    fail "systemctl --user start $1 failed"
  }
  ok "systemctl --user start $1"
}

# wait_until SECONDS CMD...: poll CMD every 100ms until it succeeds.
wait_until() {
  local secs=$1 i
  shift
  for ((i = 0; i < secs * 10; i++)); do
    "$@" && return 0
    sleep 0.1
  done
  return 1
}

_state_is() { [[ "$(prop "$1" ActiveState)" == "$2" ]]; }

# wait_state UNIT STATE [SECONDS]
wait_state() {
  wait_until "${3:-10}" _state_is "$1" "$2" ||
    fail "$1 never became $2 (it is $(prop "$1" ActiveState), result $(prop "$1" Result))"
  ok "$1 is $2"
}

# mark: remember the end of the journal; unit_log only shows what came after.
mark() {
  CURSOR=$(journalctl --user -n 0 --show-cursor --no-pager 2>/dev/null | sed -n 's/^-- cursor: //p')
}

# unit_log_json UNIT: journal entries (JSON, one per line) written by UNIT's processes since `mark`.
unit_log_json() {
  local u=$1 ident
  ident=$(prop "$u" SyslogIdentifier)
  [[ -n "$ident" && "$ident" != *%* ]] || ident=${u%.*}
  journalctl --user ${CURSOR:+--after-cursor "$CURSOR"} -o json --no-pager 2>/dev/null |
    jq -c --arg u "$u" --arg id "$ident" \
      'select(._SYSTEMD_USER_UNIT == $u or (.SYSLOG_IDENTIFIER == $id and (.USER_UNIT == null)))'
}

# unit_log UNIT: the messages alone.
unit_log() { unit_log_json "$1" | jq -r '.MESSAGE | if type == "array" then implode else . end'; }

_log_has() { unit_log "$1" | grep -qE -- "$2"; }

# wait_log UNIT REGEX [SECONDS]: wait for a matching journal line from UNIT.
wait_log() {
  wait_until "${3:-10}" _log_has "$1" "$2" || {
    echo "journal of $1 since the check started:"
    unit_log "$1" | tail -n 15 | sed 's/^/    /'
    fail "$1 never logged a line matching /$2/"
  }
  ok "$1 logged /$2/"
}

# data PATH: absolute path of a file inside the copied exercise (%t/systemdlings/<exercise>/PATH).
data() { echo "$DATA/$1"; }

# calendar_specs FILE: the OnCalendar= values of a timer file, one per line.
calendar_specs() { sed -n 's/^[[:space:]]*OnCalendar=[[:space:]]*//p' "$1"; }

# next_elapses N BASE SPEC...: the first N times (UTC) at which any of the
# calendar specs fires after BASE, merged and sorted, as "Mon 2026-10-05 09:30:00".
next_elapses() {
  local n=$1 base=$2 out
  shift 2
  out=$(TZ=UTC systemd-analyze calendar --iterations="$n" --base-time="$base" "$@" 2>&1) || {
    echo "$out" | sed 's/^/    /'
    fail "systemd-analyze calendar rejects the schedule"
  }
  grep -E 'Next elapse:|Iteration #' <<<"$out" |
    grep -oE '[A-Z][a-z]{2} [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}' |
    sort -k2,3 -u | head -n "$n"
}

# port_free PORT: fail early if something on this machine already listens on 127.0.0.1:PORT.
port_free() {
  if (exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null; then
    fail "something already listens on 127.0.0.1:$1; stop it (or run \`systemdlings clean\`) and retry"
  fi
}

# ask PORT LINE: connect to 127.0.0.1:PORT, send LINE, print the reply (3s max).
ask() {
  timeout 3 bash -c 'exec 3<>"/dev/tcp/127.0.0.1/$1" || exit 1; [[ -z "$2" ]] || printf "%s\n" "$2" >&3; cat <&3 2>/dev/null' _ "$1" "$2"
}

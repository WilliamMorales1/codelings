# Shared helpers for redislings checks. Source it first thing:
#   source "$REDISLINGS_ROOT/checks/lib.sh"
# The check runs with cwd = the exercise directory; exit 0 means pass.

set -uo pipefail

: "${REDISLINGS_ROOT:?run checks through redislings}"
: "${REDISLINGS_BIN:?run checks through redislings}"

_cleanup_pids=()
_cleanup_dirs=()
_cleanup_cmds=()

_cleanup() {
  local c p d
  for c in "${_cleanup_cmds[@]}"; do eval "$c" >/dev/null 2>&1; done
  for p in "${_cleanup_pids[@]}"; do kill "$p" 2>/dev/null; done
  for p in "${_cleanup_pids[@]}"; do wait "$p" 2>/dev/null; done
  for d in "${_cleanup_dirs[@]}"; do rm -rf "$d"; done
}
trap _cleanup EXIT

on_exit() { _cleanup_cmds+=("$1"); }

fail() {
  echo "FAIL: $*"
  exit 1
}

ok() { echo "ok: $*"; }

# expect_eq ACTUAL EXPECTED WHAT
expect_eq() {
  if [[ "$1" != "$2" ]]; then
    printf 'FAIL: %s\n  expected:\n%s\n  got:\n%s\n' "$3" "$(sed 's/^/    /' <<<"$2")" "$(sed 's/^/    /' <<<"$1")"
    exit 1
  fi
  ok "$3"
}

# expect_match ACTUAL REGEX WHAT
expect_match() {
  if [[ ! "$1" =~ $2 ]]; then
    fail "$3: '$1' does not match /$2/"
  fi
  ok "$3"
}

# expect_between N LO HI WHAT
expect_between() {
  [[ "$1" =~ ^-?[0-9]+$ ]] || fail "$4: expected a number, got '$1'"
  if (($1 < $2 || $1 > $3)); then
    fail "$4: expected $2..$3, got $1"
  fi
  ok "$4"
}

need_file() {
  local f
  for f in "$@"; do
    [[ -f "$f" ]] || fail "missing file $f"
  done
}

scratch_dir() {
  local d
  d=$(mktemp -d "${TMPDIR:-/tmp}/redislings-XXXXXX")
  _cleanup_dirs+=("$d")
  echo "$d"
}

free_port() { "$REDISLINGS_BIN" port; }

# background LOGFILE CMD...: start CMD in the background, stopped automatically when the check ends.
background() {
  local log=$1
  shift
  "$@" >"$log" 2>&1 &
  _cleanup_pids+=($!)
  LAST_PID=$!
}

: "${REDIS_SERVER:=$(command -v valkey-server || command -v redis-server)}"
: "${REDIS_CLI_BIN:=$(command -v valkey-cli || command -v redis-cli)}"

_wait_ready() {
  local i
  for ((i = 0; i < 100; i++)); do
    [[ "$("$REDIS_CLI_BIN" -p "$PORT" "${_auth[@]}" PING 2>/dev/null)" == PONG ]] && return 0
    kill -0 "$SERVER_PID" 2>/dev/null || return 1
    sleep 0.05
  done
  return 1
}

_auth=()

# start_redis [CONF] [SERVER ARGS...]: throwaway server on a free port, nothing persisted. Sets PORT, RDIR, SERVER_PID.
start_redis() {
  local conf=()
  if [[ $# -gt 0 && "$1" != --* ]]; then
    conf=("$1")
    shift
  fi
  start_redis_raw "${conf[@]}" --save '' --appendonly no "$@"
}

# start_redis_raw [ARGS...]: like start_redis, without the no-persistence defaults (a config file may come first).
start_redis_raw() {
  local conf=()
  if [[ $# -gt 0 && "$1" != --* ]]; then
    conf=("$1")
    shift
  fi
  [[ -n "${RDIR:-}" ]] || RDIR=$(scratch_dir)
  PORT=$(free_port) || fail "no free port"
  [[ ${#conf[@]} -eq 0 || -f "${conf[0]}" ]] || fail "missing file ${conf[0]}"
  background "$RDIR/server.log" "$REDIS_SERVER" "${conf[@]}" --port "$PORT" --bind 127.0.0.1 --dir "$RDIR" \
    --daemonize no --loglevel warning "$@"
  SERVER_PID=$LAST_PID
  _wait_ready || fail "server did not start:
$(tail -n 20 "$RDIR/server.log")"
}

# stop_redis: SIGKILL, so nothing is flushed on the way down (a crash, not a clean shutdown).
stop_redis() {
  kill -9 "$SERVER_PID" 2>/dev/null
  wait "$SERVER_PID" 2>/dev/null
}

# r ARGS...: one command, raw reply (what scripts see).
r() { "$REDIS_CLI_BIN" -p "$PORT" "${_auth[@]}" "$@" 2>&1; }

# cli_cmd: the command line a learner script should use, exported as REDIS_CLI.
export_cli() {
  export REDIS_CLI="$REDIS_CLI_BIN -p $PORT"
  export REDIS_ADDR="127.0.0.1:$PORT"
}

# strip_comments FILE: drop comment and blank lines (redis-cli has no comment syntax).
strip_comments() { grep -v -E '^[[:space:]]*(#|$)' "$1"; }

# seed: pipe stdin (one command per line) into the server, failing on any error.
seed() {
  local out
  out=$("$REDIS_CLI_BIN" -p "$PORT" "${_auth[@]}" --no-raw 2>&1) || fail "seeding failed: $out"
  if grep -q '^(error)' <<<"$out"; then
    fail "seeding failed: $(grep '^(error)' <<<"$out" | head -3)"
  fi
}

_check_errors() {
  if grep -q -E '^(\(error\)|Error:|Could not connect)' <<<"$OUT"; then
    echo "your commands printed:"
    sed 's/^/    /' <<<"$OUT"
    fail "a command returned an error: $(grep -m1 -E '^(\(error\)|Error:|Could not connect)' <<<"$OUT")"
  fi
}

# run_file FILE: pipe the learner's commands into redis-cli; output in OUT, failing on any error reply.
run_file() {
  need_file "$1"
  OUT=$(strip_comments "$1" | "$REDIS_CLI_BIN" -p "$PORT" --no-raw 2>&1)
  _check_errors
}

# run_file_paused FILE HOOK: like run_file, but at the "# --- PAUSE ---" line the connection stays open
# while HOOK (a shell command) runs from a second client.
run_file_paused() {
  need_file "$1"
  local first second
  first=$(awk '/^# --- PAUSE/{exit} {print}' "$1" | grep -v -E '^[[:space:]]*(#|$)')
  second=$(awk 'p{print} /^# --- PAUSE/{p=1}' "$1" | grep -v -E '^[[:space:]]*(#|$)')
  grep -q '^# --- PAUSE' "$1" || fail "the '# --- PAUSE ---' line is missing from $1; put it back"
  local out="$RDIR/paused.out"
  { printf '%s\n' "$first"; sleep 0.6; printf '%s\n' "$second"; } | "$REDIS_CLI_BIN" -p "$PORT" --no-raw >"$out" 2>&1 &
  local pid=$!
  sleep 0.3
  eval "$2"
  wait "$pid"
  OUT=$(cat "$out")
  _check_errors
}

# forbid FILE REGEX WHY: fail when a (non-comment) line of FILE matches REGEX, case-insensitively.
forbid() {
  if strip_comments "$1" | grep -q -i -E "$2"; then
    fail "$3"
  fi
}

# require FILE REGEX WHY: fail unless some (non-comment) line of FILE matches REGEX, case-insensitively.
require() {
  strip_comments "$1" | grep -q -i -E "$2" || fail "$3"
}

# flush: empty the server between scenarios.
flush() { r FLUSHALL >/dev/null; }

# rn ARGS...: one command, formatted like interactive redis-cli (and like run_file's OUT).
rn() { "$REDIS_CLI_BIN" -p "$PORT" "${_auth[@]}" --no-raw "$@" 2>&1; }

# members TEXT: the elements of a --no-raw array reply, one per line, sorted (for sets, where order is undefined).
members() { sed -n -E 's/^ *[0-9]+\) "(.*)"$/\1/p' <<<"$1" | sort; }

# listen FILE|- SECONDS: run subscribe commands (from FILE, or stdin with -) on a connection held open
# for SECONDS, output in $RDIR/listen.out. Returns once the server reports a subscription.
listen() {
  local cmds secs=$2 i
  if [[ "$1" == - ]]; then cmds=$(cat); else cmds=$(strip_comments "$1"); fi
  printf '%s\n' "$cmds" >"$RDIR/listen.in"
  # Everything goes to the file: a leftover sleep must not hold the check's stdout open.
  bash -c '{ cat "$1"; sleep "$2"; } | timeout "$2" "$3" -p "$4" --no-raw' _ \
    "$RDIR/listen.in" "$secs" "$REDIS_CLI_BIN" "$PORT" >"$RDIR/listen.out" 2>&1 &
  LISTEN_PID=$!
  for ((i = 0; i < 40; i++)); do
    [[ "$(r PUBSUB NUMPAT)" != 0 || -n "$(r PUBSUB CHANNELS)" ]] && return 0
    sleep 0.05
  done
  return 1
}

# listen_wait: wait for the listener to finish; its output ends up in LISTENED.
listen_wait() {
  wait "$LISTEN_PID" 2>/dev/null
  LISTENED=$(cat "$RDIR/listen.out")
}

# r_as USER PASS ARGS...: one command as another ACL user.
r_as() {
  local u=$1 p=$2
  shift 2
  "$REDIS_CLI_BIN" -p "$PORT" --user "$u" --pass "$p" --no-auth-warning "$@" 2>&1
}

# go_build: compile the exercise's *.go against the course's go.mod into $PROG.
go_build() {
  local b
  b=$(scratch_dir)
  cp ./*.go "$b/" 2>/dev/null || fail "no .go files here"
  cp "$REDISLINGS_ROOT/checks/09_go_client/gomod/go.mod" "$REDISLINGS_ROOT/checks/09_go_client/gomod/go.sum" "$b/"
  local out
  # GOTOOLCHAIN=local: never download a toolchain; GOFLAGS=-mod=mod: go.sum pins the rest.
  out=$(cd "$b" && GOTOOLCHAIN=local GOFLAGS=-mod=mod go build -o prog . 2>&1) || {
    echo "$out"
    fail "go build failed (the first build downloads go-redis, so it needs the network once)"
  }
  PROG="$b/prog"
}

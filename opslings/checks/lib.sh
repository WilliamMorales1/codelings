# Shared helpers for opslings checks. Source it first thing:
#   source "$OPSLINGS_ROOT/checks/lib.sh"
# The check runs with cwd = the exercise directory; exit 0 means pass.

set -uo pipefail

: "${OPSLINGS_ROOT:?run checks through opslings}"
: "${OPSLINGS_BIN:?run checks through opslings}"

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

# on_exit CMD: run CMD (a string) when the check ends, pass or fail.
on_exit() { _cleanup_cmds+=("$1"); }

fail() {
  echo "FAIL: $*"
  exit 1
}

ok() { echo "ok: $*"; }

# expect_eq ACTUAL EXPECTED WHAT
expect_eq() {
  if [[ "$1" != "$2" ]]; then
    fail "$3: expected '$2', got '$1'"
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

need_file() {
  local f
  for f in "$@"; do
    [[ -f "$f" ]] || fail "missing file $f"
  done
}

# yqv EXPR FILE: evaluate a yq expression (all documents), print the result.
yqv() { yq eval "$1" "$2" 2>&1; }

# expect_yq FILE EXPR EXPECTED WHAT
expect_yq() {
  local got
  got=$(yq eval "$2" "$1" 2>&1) || fail "yq could not read $1: $got"
  expect_eq "$got" "$3" "$4"
}

# kubeval FILE...: strict schema validation. Schemas are cached, so only the first run needs the network.
kubeval() {
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/opslings/kubeconform"
  mkdir -p "$cache"
  local out
  out=$(kubeconform -strict -summary -kubernetes-version 1.35.0 -cache "$cache" "$@" 2>&1) || {
    echo "$out"
    fail "kubeconform rejected the manifest"
  }
  ok "kubeconform -strict accepts $*"
}

# scratch_copy: copy the exercise to a throwaway dir and cd into it, so tools that write state leave no mess.
scratch_copy() {
  local d
  d=$(mktemp -d "${TMPDIR:-/tmp}/opslings-XXXXXX")
  _cleanup_dirs+=("$d")
  cp -a . "$d/work"
  cd "$d/work" || fail "cannot enter scratch dir"
  SCRATCH="$d"
}

free_port() { "$OPSLINGS_BIN" port; }

# background LOGFILE CMD...: start CMD in the background, stopped automatically when the check ends.
background() {
  local log=$1
  shift
  "$@" >"$log" 2>&1 &
  _cleanup_pids+=($!)
  LAST_PID=$!
}

# wait_http URL [SECONDS]: poll until something answers on URL.
wait_http() {
  local url=$1 secs=${2:-10} i
  for ((i = 0; i < secs * 10; i++)); do
    curl -s -o /dev/null --max-time 1 "$url" && return 0
    sleep 0.1
  done
  return 1
}

# start_target: run `opslings target` on a free port; sets TARGET_URL.
start_target() {
  local port
  port=$(free_port) || fail "no free port"
  local log
  log=$(mktemp "${TMPDIR:-/tmp}/opslings-target-XXXXXX.log")
  _cleanup_dirs+=("$log")
  background "$log" "$OPSLINGS_BIN" target --quiet --port "$port"
  TARGET_URL="http://127.0.0.1:$port"
  wait_http "$TARGET_URL/" 10 || fail "opslings target did not start: $(cat "$log")"
  reset_target
}

# stat_count KEY: how many requests the target saw for "METHOD path status".
stat_count() {
  curl -s "$TARGET_URL/__stats" | jq -r --arg k "$1" '.requests[$k] // 0'
}

# stat_sum REGEX: total requests whose "METHOD path status" key matches REGEX.
stat_sum() {
  curl -s "$TARGET_URL/__stats" | jq -r --arg r "$1" '[.requests | to_entries[] | select(.key | test($r)) | .value] | add // 0'
}

# need_docker: fail early with a useful message when the daemon is down.
need_docker() {
  docker info >/dev/null 2>&1 || fail "docker is installed but the daemon is not reachable (sudo systemctl start docker.socket; are you in the docker group?)"
}

# docker_build TAG [ARGS...]: build the current directory, printing the build log only on failure.
docker_build() {
  local tag=$1 out
  shift
  out=$(docker build -t "$tag" "$@" . 2>&1) || {
    echo "$out" | tail -25
    fail "docker build failed"
  }
  ok "docker build -t $tag $*"
}

# docker_detached NAME ARGS...: docker run -d, removed when the check ends.
docker_detached() {
  local name=$1
  shift
  docker rm -f "$name" >/dev/null 2>&1
  docker run -d --name "$name" "$@" >/dev/null || fail "docker run failed"
  on_exit "docker rm -f $name"
}

# helm_render OUTFILE ARGS...: `helm template demo . ARGS...` into OUTFILE, failing on errors.
helm_render() {
  local out=$1 err
  shift
  err=$(helm template demo . "$@" 2>&1 >"$out") || {
    echo "$err"
    fail "helm template demo . $* failed"
  }
}

# helm_lint: `helm lint .` must report no errors.
helm_lint() {
  local out
  out=$(helm lint . 2>&1) || {
    echo "$out"
    fail "helm lint reported errors"
  }
  ok "helm lint passes"
}

# k6_run ARGS...: run k6 against the target; sets K6_RC and K6_OUT (combined output).
k6_run() {
  K6_OUT=$(k6 run --quiet --no-usage-report --no-color -e BASE_URL="$TARGET_URL" "$@" 2>&1)
  K6_RC=$?
}

# k6_ok ARGS...: k6_run that must succeed (exit 0).
k6_ok() {
  k6_run "$@"
  if ((K6_RC != 0)); then
    echo "$K6_OUT" | grep -v '^\s*$' | tail -20
    fail "k6 run exited with $K6_RC"
  fi
  ok "k6 run $* (exit 0)"
}

# k6_opt EXPR: evaluate a jq expression over `k6 inspect script.js`.
k6_opt() {
  k6 inspect script.js 2>&1 | jq -c "$1" 2>/dev/null || fail "k6 inspect script.js failed: $(k6 inspect script.js 2>&1 | tail -3)"
}

reset_target() { curl -s -X POST "$TARGET_URL/__reset" >/dev/null; }

# prom_test NAME: run checks/06_prometheus/tests/NAME.yml (a promtool unit test) beside the learner's rules.
prom_test() {
  local out
  scratch_copy
  cp "$OPSLINGS_ROOT/checks/06_prometheus/tests/$1.yml" ./opslings-test.yml
  out=$(promtool test rules opslings-test.yml 2>&1) || {
    echo "$out"
    fail "promtool test rules: the rules do not behave as specified (expected vs got above)"
  }
  ok "promtool test rules: alerts and recordings behave as specified"
}

# prom_check_rules FILE: promtool check rules must accept FILE.
prom_check_rules() {
  local out
  out=$(promtool check rules "$1" 2>&1) || {
    echo "$out"
    fail "promtool check rules rejected $1"
  }
  ok "promtool check rules $1"
}

# tofu_test NAME: copy the module to scratch, add checks/07_opentofu/tests/NAME.tftest.hcl, init and test.
tofu_test() {
  local out
  scratch_copy
  rm -rf .terraform .terraform.lock.hcl terraform.tfstate*
  cp "$OPSLINGS_ROOT/checks/07_opentofu/tests/$1.tftest.hcl" ./opslings.tftest.hcl
  out=$(tofu init -input=false -no-color 2>&1) || {
    echo "$out" | tail -20
    fail "tofu init failed"
  }
  ok "tofu init"
  out=$(tofu test -no-color 2>&1) || {
    echo "$out" | grep -v "^\s*$" | head -45
    fail "tofu test failed"
  }
  echo "$out" | grep -E '^\s+run ' | sed 's/^\s*/ok: /'
}

# caddy_start [VAR=value...]: run `caddy run` on ./Caddyfile with PORT set to a free port; sets CADDY_URL.
caddy_start() {
  local port d
  port=$(free_port) || fail "no free port"
  d=$(mktemp -d "${TMPDIR:-/tmp}/opslings-caddy-XXXXXX")
  _cleanup_dirs+=("$d")
  out=$(env "$@" PORT="$port" caddy validate --config Caddyfile --adapter caddyfile 2>&1) || {
    echo "$out" | grep -v '"level":"info"' | tail -5
    fail "caddy validate rejected the Caddyfile"
  }
  ok "caddy validate"
  # Private data/config dirs: caddy autosaves its config and would otherwise write to ~/.config.
  background "$d/caddy.log" env "$@" PORT="$port" XDG_DATA_HOME="$d/data" XDG_CONFIG_HOME="$d/config" \
    caddy run --config Caddyfile --adapter caddyfile
  CADDY_URL="http://127.0.0.1:$port"
  wait_http "$CADDY_URL/" 10 || { tail -5 "$d/caddy.log"; fail "caddy did not start"; }
}

# http_status URL: print only the HTTP status code.
http_status() { curl -s -o /dev/null -w '%{http_code}' "$@"; }

# http_header URL NAME: print one response header's value (empty when absent).
http_header() {
  curl -s -o /dev/null -D - "$1" | tr -d '\r' | awk -v IGNORECASE=1 -v h="$2" 'tolower($0) ~ "^" tolower(h) ":" { sub(/^[^:]*: */, ""); print; exit }'
}

# kc ARGS...: kubectl against the course's kind cluster, never your current context.
kc() { kubectl --context kind-opslings "$@"; }

# live_part: stop here (passing) during `opslings selftest`, which only checks the files.
live_part() {
  if [[ -n "${OPSLINGS_SELFTEST:-}" ]]; then
    ok "selftest: skipping the live-cluster assertions"
    exit 0
  fi
}

# need_cluster: the kind cluster from cluster1 must be up.
need_cluster() {
  kind get clusters 2>/dev/null | grep -qx opslings ||
    fail "no kind cluster named opslings: do exercise cluster1 first (kind create cluster --config exercises/09_cluster/cluster1/kind.yaml)"
  kc get --raw /readyz >/dev/null 2>&1 || fail "cluster opslings exists but its API server does not answer (is docker running?)"
  ok "cluster opslings is up"
}

# wait_for SECONDS CMD...: retry CMD once a second until it succeeds.
wait_for() {
  local secs=$1 i
  shift
  for ((i = 0; i < secs; i++)); do
    "$@" >/dev/null 2>&1 && return 0
    sleep 1
  done
  return 1
}

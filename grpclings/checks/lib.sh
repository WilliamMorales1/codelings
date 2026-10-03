# Shared helpers for grpclings checks. Source it first thing:
#   source "$GRPCLINGS_LIB"
# The check runs with cwd = the exercise directory; exit 0 means pass.

set -uo pipefail

: "${GRPCLINGS_ROOT:?run checks through grpclings}"
: "${GRPCLINGS_BIN:?run checks through grpclings}"
: "${EXERCISE_ID:?run checks through grpclings}"

CHAPTER=${EXERCISE_ID%/*}

_cleanup_pids=()
_cleanup_dirs=()

_cleanup() {
  local p d
  for p in "${_cleanup_pids[@]}"; do kill "$p" 2>/dev/null; done
  for p in "${_cleanup_pids[@]}"; do wait "$p" 2>/dev/null; done
  for d in "${_cleanup_dirs[@]}"; do rm -rf "$d"; done
}
trap _cleanup EXIT

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

need_file() {
  local f
  for f in "$@"; do
    [[ -f "$f" ]] || fail "missing file $f"
  done
}

tmpdir() {
  local d
  d=$(mktemp -d "${TMPDIR:-/tmp}/grpclings-XXXXXX")
  _cleanup_dirs+=("$d")
  echo "$d"
}

# scratch_copy: copy the exercise to a throwaway dir and cd into it, so generators leave no mess.
scratch_copy() {
  SCRATCH=$(tmpdir)
  cp -a . "$SCRATCH/work"
  cd "$SCRATCH/work" || fail "cannot enter scratch dir"
}

free_port() { "$GRPCLINGS_BIN" port; }

# tool_path NAME: the binary of a `tool` directive in go.mod, built once and cached by Go.
tool_path() { (cd "$GRPCLINGS_ROOT" && go tool -n "$1"); }

# run_buf ARGS...: buf from PATH, else the version pinned in go.mod.
run_buf() {
  if command -v buf >/dev/null; then
    buf "$@"
  else
    "$(tool_path buf)" "$@"
  fi
}

# gen_go SRC OUT: protoc + protoc-gen-go + protoc-gen-go-grpc over SRC/*.proto, output in OUT.
gen_go() {
  local src=$1 out=$2 protos
  mapfile -t protos < <(cd "$src" && ls *.proto 2>/dev/null)
  [[ ${#protos[@]} -gt 0 ]] || return 0
  mkdir -p "$out"
  local pgg pggg
  pgg=$(tool_path protoc-gen-go) || fail "cannot build protoc-gen-go"
  pggg=$(tool_path protoc-gen-go-grpc) || fail "cannot build protoc-gen-go-grpc"
  local msg
  if ! msg=$(cd "$src" && protoc -I . \
    --plugin=protoc-gen-go="$pgg" --plugin=protoc-gen-go-grpc="$pggg" \
    --go_out="$out" --go_opt=paths=source_relative \
    --go-grpc_out="$out" --go-grpc_opt=paths=source_relative \
    "${protos[@]}" 2>&1); then
    echo "protoc rejected the .proto files:"
    echo "$msg" | sed 's/^/  /'
    return 1
  fi
}

# go_check [--no-regen]: regenerate Go code from the exercise's .proto files, add the
# hidden test checks/<chapter>/<name>_test.go, and `go test` the exercise package.
# Both are laid over the exercise with `go test -overlay`: nothing is written into it.
go_check() {
  local regen=1
  [[ "${1:-}" == "--no-regen" ]] && regen=0
  local dir test tmp rel
  dir=$(pwd -P)
  test="$GRPCLINGS_ROOT/checks/$CHAPTER/${EXERCISE_NAME}_test.go"
  need_file "$test"
  tmp=$(tmpdir)
  if ((regen)); then
    gen_go "$dir" "$tmp/gen" || exit 1
  fi
  local args=(--arg test "$test" --arg dir "$dir")
  local f files=()
  if [[ -d "$tmp/gen" ]]; then
    for f in "$tmp"/gen/*.go; do files+=("$(basename "$f")"); done
  fi
  jq -n "${args[@]}" --arg gen "$tmp/gen" '
    {Replace: ({($dir + "/grpclings_check_test.go"): $test}
      + ($ARGS.positional | map({key: ($dir + "/" + .), value: ($gen + "/" + .)}) | from_entries))}
  ' --args "${files[@]}" >"$tmp/overlay.json" || fail "cannot write overlay"
  rel=$(realpath --relative-to="$GRPCLINGS_ROOT" "$dir")
  cd "$GRPCLINGS_ROOT" || fail "cannot enter course root"
  go test -tags check -count=1 -timeout 60s -overlay "$tmp/overlay.json" "./$rel" 2>&1 |
    grep -v -e '^FAIL$' -e '^FAIL[[:space:]]grpclings/' -e '^ok[[:space:]]'
  local rc=${PIPESTATUS[0]}
  ((rc == 0)) || exit 1
  ok "go test passes"
}

# module_scratch: copy the exercise to a throwaway dir INSIDE the Go module and
# cd into it, so generators can run `go tool` and the result can be `go test`ed.
module_scratch() {
  local d
  d=$(mktemp -d "$GRPCLINGS_ROOT/_scratch-XXXXXX")
  _cleanup_dirs+=("$d")
  cp -a . "$d/$EXERCISE_NAME"
  cd "$d/$EXERCISE_NAME" || fail "cannot enter scratch dir"
}

# buf_image: build the buf workspace in the cwd into a JSON image; sets IMAGE.
buf_image() {
  IMAGE="$(tmpdir)/image.json"
  local out
  out=$(run_buf build --exclude-source-info -o "$IMAGE" 2>&1) || { echo "$out"; fail "buf build failed"; }
}

# img JQ: query IMAGE (a FileDescriptorSet in JSON, camelCase keys).
img() { jq -r "$1" "$IMAGE"; }

# msg_json FULLNAME: the descriptor of message pkg.Name from IMAGE, or empty.
msg_json() {
  local pkg=${1%.*} name=${1##*.}
  jq -c --arg p "$pkg" --arg n "$name" '.file[] | select(.package == $p) | .messageType[]? | select(.name == $n)' "$IMAGE"
}

# expect_buf_lint: `buf lint` must be clean.
expect_buf_lint() {
  local out
  out=$(run_buf lint 2>&1) || { echo "$out"; fail "buf lint found problems"; }
  ok "buf lint is clean"
}

# expect_buf_breaking AGAINST: no breaking changes relative to AGAINST.
expect_buf_breaking() {
  local out
  out=$(run_buf breaking --against "$1" 2>&1) || { echo "$out"; fail "buf breaking found breaking changes against $1/"; }
  ok "buf breaking: compatible with $1/"
}

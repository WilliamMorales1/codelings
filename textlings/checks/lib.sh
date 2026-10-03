# Shared helpers for textlings checks. Source it first thing:
#   source "$TEXTLINGS_ROOT/checks/lib.sh"
# The check runs with cwd = the exercise directory; exit 0 means pass.
# $FIX is checks/<chapter>/fixtures/<exercise>: hidden inputs and their expected output.

set -uo pipefail
export LC_ALL=C

: "${TEXTLINGS_ROOT:?run checks through textlings}"

# POSIX chapters run under `gawk --posix`, which rejects gawk extensions.
# TEXTLINGS_AWK swaps in another awk (verify-all.sh also runs them under nawk, the one true awk).
read -ra POSIX_AWK <<<"${TEXTLINGS_AWK:-gawk --posix}"

_TL_TMP=$(mktemp -d "${TMPDIR:-/tmp}/textlings-XXXXXX")
trap 'rm -rf "$_TL_TMP"' EXIT
_TL_N=0

fail() {
  echo "FAIL: $*"
  exit 1
}

ok() { echo "ok: $*"; }

need_file() {
  local f
  for f in "$@"; do
    [[ -f "$f" ]] || fail "missing file $f"
  done
}

# _norm: drop trailing whitespace on each line and trailing blank lines, so an
# extra space or final newline never decides pass/fail.
_norm() {
  sed -e 's/[[:space:]]*$//' | sed -e ':a' -e '/^\n*$/{$d;N;ba' -e '}'
}

# _prog KIND: fill PROG with the command line for the learner's program.
_prog() {
  PROG=()
  case $1 in
    jq)
      need_file filter.jq
      local flags=()
      if [[ -f flags ]]; then
        # flags holds shell words, e.g. `-r` or `--slurp -c`; lines starting with # are comments.
        eval "flags=( $(grep -v '^[[:space:]]*#' flags) )" || fail "could not parse the flags file"
      fi
      PROG=(jq "${flags[@]}" -f filter.jq)
      ;;
    awk)
      need_file prog.awk
      PROG=("${POSIX_AWK[@]}" -f prog.awk)
      ;;
    gawk)
      need_file prog.awk
      PROG=(gawk -f prog.awk)
      ;;
    sh)
      need_file pipeline.sh
      PROG=(bash pipeline.sh)
      ;;
    *) fail "check bug: unknown program kind $1" ;;
  esac
}

# expect_out [--sort] [--stdin FILE] [--label TEXT] KIND EXPECTED -- ARGS...
# Runs the learner's program (KIND: jq, awk, gawk, sh) with ARGS and compares
# its stdout with the EXPECTED file. --sort compares both sides sorted, for
# output whose order the language does not define (awk's for-in).
expect_out() {
  local sort=0 stdin=/dev/null label=""
  while [[ $1 == --* ]]; do
    case $1 in
      --sort) sort=1; shift ;;
      --stdin) stdin=$2; shift 2 ;;
      --label) label=$2; shift 2 ;;
      *) fail "check bug: unknown option $1" ;;
    esac
  done
  local kind=$1 expected=$2
  shift 2
  [[ ${1:-} == -- ]] && shift
  _prog "$kind"
  local cmd=("${PROG[@]}" "$@")

  local shown="${cmd[*]}"
  shown=${shown//"$FIX/"/"<hidden>/"}
  [[ $stdin != /dev/null ]] && shown+=" < ${stdin/#"$FIX/"/<hidden>/}"
  [[ -z $label ]] && label="output of: $shown"

  local tmp=$_TL_TMP/$((++_TL_N))
  mkdir -p "$tmp"
  # timeout: a getline loop that never sees EOF must fail, not hang the runner.
  timeout 5 "${cmd[@]}" <"$stdin" >"$tmp/got.raw" 2>"$tmp/err"
  local status=$?
  ((status == 124)) && echo "program killed after 5 seconds (endless loop? waiting on stdin?)" >>"$tmp/err"
  if ((status != 0)); then
    echo "FAIL: $label"
    echo "  ran: $shown"
    echo "  exit status $status, stderr:"
    sed 's/^/    /' "$tmp/err" | head -20
    exit 1
  fi
  _norm <"$tmp/got.raw" >"$tmp/got"
  # Maintainers: TEXTLINGS_RECORD=1 writes a missing expected file from this output (scripts/record.sh).
  if [[ ${TEXTLINGS_RECORD:-} == 1 && ! -e $expected ]]; then
    mkdir -p "$(dirname "$expected")"
    cp "$tmp/got" "$expected"
    ok "recorded $expected"
    return 0
  fi
  _norm <"$expected" >"$tmp/want"
  if ((sort)); then
    sort -o "$tmp/got" "$tmp/got"
    sort -o "$tmp/want" "$tmp/want"
  fi
  if ! cmp -s "$tmp/want" "$tmp/got"; then
    echo "FAIL: $label"
    echo "  ran: $shown"
    if [[ -s $tmp/err ]]; then
      echo "  stderr:"
      sed 's/^/    /' "$tmp/err" | head -10
    fi
    echo "  diff (- expected, + yours):"
    diff -u --label expected --label yours "$tmp/want" "$tmp/got" | tail -n +3 | head -40 | sed 's/^/    /'
    exit 1
  fi
  ok "$label"
}

# _code FILE: the program with whole-line comments removed, for must_use/must_not_use.
_code() { grep -v '^[[:space:]]*#' "$1"; }

# must_use FILE REGEX WHAT: the program must contain REGEX (outside comments).
must_use() {
  _code "$1" | grep -Eq -- "$2" || fail "$1 should use $3"
  ok "$1 uses $3"
}

# must_not_use FILE REGEX WHAT
must_not_use() {
  if _code "$1" | grep -Eq -- "$2"; then
    fail "$1 must not use $3"
  fi
  ok "$1 avoids $3"
}

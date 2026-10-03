#!/usr/bin/env bash
# Every solution must pass its check and every untouched exercise must
# fail it. Exercises whose tools are missing are reported SKIPPED.
# If the one true awk (nawk) is around, the POSIX awk chapters are checked a
# second time with it, to prove the solutions do not lean on gawk.
set -euo pipefail
cd "$(dirname "$0")/.."
bin=$(mktemp -d)/textlings
trap 'rm -rf "$(dirname "$bin")"' EXIT
go build -o "$bin" .

echo "== gawk --posix"
"$bin" selftest -j 4

nawk=${NAWK:-$(command -v nawk || true)}
if [[ -n $nawk ]]; then
  echo
  echo "== $nawk (POSIX chapters 04-07)"
  TEXTLINGS_AWK=$nawk "$bin" selftest -j 4 04 05 06 07
else
  echo
  echo "SKIPPED: nawk not found (install nawk / original-awk, or NAWK=/path/to/awk), POSIX awk solutions only checked under gawk --posix"
fi

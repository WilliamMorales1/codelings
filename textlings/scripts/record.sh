#!/usr/bin/env bash
# Maintainer tool: fill in missing expected outputs by running the reference solutions.
#   scripts/record.sh [CHAPTER_PREFIX]
# For each exercise: copy its input files into solutions/ (the solution dir must be
# complete, selftest runs the check there), run the check with TEXTLINGS_RECORD=1 so
# every missing expected file is written from the solution's output, copy expected.txt
# back into exercises/, and refresh .templates/ from exercises/.
# Delete an expected file to re-record it, then read the result before committing.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
prefix=${1:-}
for check in "$root"/checks/"$prefix"*/*.sh; do
  ch=$(basename "$(dirname "$check")")
  name=$(basename "$check" .sh)
  ex=$root/exercises/$ch/$name
  sol=$root/solutions/$ch/$name
  [[ -d $ex && -d $sol ]] || { echo "skip $ch/$name (no exercise or solution dir)"; continue; }
  for f in "$ex"/*; do
    [[ -e $sol/$(basename "$f") ]] || cp -a "$f" "$sol/"
  done
  if ! (cd "$sol" && TEXTLINGS_ROOT=$root EXERCISE_DIR=$sol EXERCISE_NAME=$name \
    FIX=$root/checks/$ch/fixtures/$name TEXTLINGS_RECORD=1 bash "$check" >/tmp/textlings-record.$$ 2>&1); then
    echo "FAILED $ch/$name"
    sed 's/^/    /' /tmp/textlings-record.$$
  else
    grep -h 'recorded' /tmp/textlings-record.$$ | sed "s|$root/||" || true
  fi
  [[ -f $sol/expected.txt ]] && cp "$sol/expected.txt" "$ex/expected.txt"
  rm -rf "$root/.templates/$ch/$name"
  mkdir -p "$root/.templates/$ch"
  cp -a "$ex" "$root/.templates/$ch/$name"
done
rm -f /tmp/textlings-record.$$

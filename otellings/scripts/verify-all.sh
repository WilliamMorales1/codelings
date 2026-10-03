#!/usr/bin/env bash
# Course maintenance: every solution passes its check, every untouched exercise
# fails it, and .templates/ matches exercises/.
# Exercises whose tools are missing (otelcol-contrib) are reported SKIPPED.
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0
if ! diff -r exercises .templates >/dev/null; then
  echo "exercises/ and .templates/ differ (reset an exercise, or copy the change over):"
  diff -rq exercises .templates || true
  fail=1
fi
go build -o otellings . || exit 1
./otellings selftest "$@" || fail=1
exit $fail

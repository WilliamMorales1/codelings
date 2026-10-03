#!/usr/bin/env bash
# Every solution passes its check, and every untouched exercise fails it.
# Chapters whose tools are missing are reported SKIPPED, never passed.
set -euo pipefail
cd "$(dirname "$0")/.."
go build -o redislings .
# .templates/ must stay a pristine copy of exercises/ as shipped.
if ! diff -r exercises .templates >/dev/null; then
  echo "exercises/ and .templates/ differ (fine while you are working through the course):"
  diff -rq exercises .templates || true
fi
exec ./redislings selftest "$@"

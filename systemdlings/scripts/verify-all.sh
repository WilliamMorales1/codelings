#!/usr/bin/env bash
# Every solution passes its check, and every untouched exercise fails it.
# Chapters whose tools are missing are reported SKIPPED, never passed.
# Usage: scripts/verify-all.sh [-j N] [CHAPTER]
set -euo pipefail
cd "$(dirname "$0")/.."
go build -o systemdlings .
if ! diff -r exercises .templates >/dev/null; then
  echo "note: exercises/ differs from .templates/ (solved or edited locally); selftest uses .templates/"
fi
exec ./systemdlings selftest "$@"

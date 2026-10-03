#!/usr/bin/env bash
# Course maintenance: every solution passes its check, every untouched exercise
# fails it. Exercises whose tools are missing are SKIPPED.
set -euo pipefail
cd "$(dirname "$0")/.."
go vet ./...
go build -o netlings .
# .templates must mirror exercises/ exactly, or `reset` hands out something else.
diff -r exercises .templates >/dev/null || { echo "exercises/ and .templates/ differ"; exit 1; }
./netlings selftest -j "${JOBS:-4}" "$@"

#!/usr/bin/env bash
# Every solution must pass its tests; every untouched exercise must fail them.
set -euo pipefail
cd "$(dirname "$0")/.."
if [ ! -d node_modules/tailwindcss ] || [ ! -d node_modules/vitest ]; then
  echo "SKIPPED: dependencies missing (run npm install)"
  exit 1
fi
exec node scripts/verify-all.mjs "$@"

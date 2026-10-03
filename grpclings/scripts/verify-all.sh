#!/usr/bin/env bash
# Every solution passes its check and every untouched exercise fails it.
# Exercises whose tools are missing are reported SKIPPED, not passed.
set -euo pipefail
cd "$(dirname "$0")/.."
go build -o grpclings .
exec ./grpclings selftest "$@"

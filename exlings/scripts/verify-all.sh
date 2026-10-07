#!/bin/bash
# Verify every solution passes its check, and every untouched exercise does not.
cd "$(dirname "$0")/.." || exit 1
if ! command -v elixir >/dev/null; then
  echo "SKIPPED: elixir not installed"; exit 0
fi
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
fail=0
for side in solutions .templates; do
  rm -rf "$work"/*
  cp -r exlings checks "$work"/
  cp -r "$side" "$work"/exercises
  for check in $(cd checks && find . -name '*.exs' | sort); do
    name=$(basename "$check" .exs)
    out=$(cd "$work" && NO_COLOR=1 ./exlings run "$name" 2>&1); rc=$?
    if [ "$side" = solutions ] && [ $rc -ne 0 ]; then
      echo "SOLUTION BROKEN: $name"; echo "$out" | head -12; fail=1
    elif [ "$side" = .templates ] && [ $rc -eq 0 ]; then
      echo "EXERCISE NOT BROKEN: $name"; fail=1
    fi
  done
done
[ $fail -eq 0 ] && echo "ALL GOOD"
exit $fail

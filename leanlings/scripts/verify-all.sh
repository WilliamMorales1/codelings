#!/bin/bash
# Verify every solution compiles, and every untouched exercise does not.
cd "$(dirname "$0")/.." || exit 1
fail=0
for f in $(find solutions -name '*.lean' | sort); do
  out=$(lean "$f" 2>&1); rc=$?
  if [ $rc -ne 0 ] || echo "$out" | grep -q "declaration uses"; then
    echo "SOLUTION BROKEN: $f"; echo "$out" | head -8; fail=1
  fi
done
for f in $(find exercises -name '*.lean' | sort); do
  out=$(lean "$f" 2>&1); rc=$?
  if [ $rc -eq 0 ] && ! echo "$out" | grep -q "declaration uses"; then
    echo "EXERCISE NOT BROKEN: $f"; fail=1
  fi
done
[ $fail -eq 0 ] && echo "ALL GOOD"

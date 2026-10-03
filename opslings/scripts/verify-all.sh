#!/bin/bash
# Verify every solution passes its check and every untouched exercise fails it.
# Chapters whose tools are missing are reported SKIPPED, never passed.
set -u
cd "$(dirname "$0")/.." || exit 1
fail=0

go build -o opslings . || exit 1

# .templates/ is what `reset` restores and what selftest strips; it must match exercises/.
if ! diff -r exercises .templates >/dev/null; then
  echo "exercises/ and .templates/ differ:"
  diff -rq exercises .templates
  fail=1
fi

for d in exercises/*/*/; do
  d=${d%/}
  rel=${d#exercises/}
  [[ -f "checks/$rel.sh" ]] || { echo "NO CHECK: $d"; fail=1; }
  [[ -d "solutions/$rel" ]] || { echo "NO SOLUTION: $d"; fail=1; }
done

./opslings selftest "$@" || fail=1

[ $fail -eq 0 ] && echo "ALL GOOD"
exit $fail

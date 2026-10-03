#!/usr/bin/env bash
# Checks the course itself: every solution passes (typecheck + tests), every
# untouched exercise fails, and .templates/ matches exercises/.
set -uo pipefail
cd "$(dirname "$0")/.."
export NO_COLOR=1
status=0
fail() { echo "FAIL: $*"; status=1; }

if [[ ! -d node_modules/typescript || ! -d node_modules/vitest ]]; then
  echo "SKIPPED: node_modules missing (run npm install)"
  exit 1
fi

echo "== runner typechecks (erasable syntax only)"
node node_modules/typescript/bin/tsc -p tsconfig.runner.json --pretty false || fail "runner has type errors"

echo "== every exercise has a solution and a template"
while IFS= read -r t; do
  rel=${t#tests/}; id=${rel%.test.ts}; ch=${id%/*}; name=${id#*/}
  ex=exercises/$ch/$name; [[ -e $ex ]] || ex=$ex.ts
  [[ -e $ex ]] || { fail "$id: no exercise"; continue; }
  sol=solutions/${ex#exercises/}
  [[ -e $sol ]] || { fail "$id: no solution"; continue; }
done < <(find tests -name '*.test.ts' | sort)
diff -r exercises .templates >/dev/null || fail ".templates/ differs from exercises/ (diff -r exercises .templates)"

echo "== solutions pass"
out=$(TSLINGS_SRC=solutions node tslings.ts list)
total=$(grep -cE '^(DONE|FAILED|PENDING)' <<<"$out")
bad=$(grep -vE '^DONE' <<<"$out" | grep -E '^(FAILED|PENDING)' || true)
[[ -z $bad ]] || fail "solutions not passing:"$'\n'"$bad"
echo "$((total - $(grep -cE '^(FAILED|PENDING)' <<<"$out"))) / $total solutions pass"

echo "== untouched exercises fail"
out=$(TSLINGS_SRC=.templates node tslings.ts list)
while read -r state id _; do
  [[ $state == PENDING ]] || fail "$id passes without being fixed (got $state)"
done < <(grep -E '^(DONE|PENDING)' <<<"$out")
echo "$(grep -cE '^PENDING' <<<"$out") untouched exercises fail"

[[ $status == 0 ]] && echo "ALL OK" || echo "PROBLEMS FOUND"
exit $status

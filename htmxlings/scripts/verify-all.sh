#!/bin/bash
# Verify every solution passes its tests, and every untouched exercise fails them.
# The stripped copy lives inside the repo (.verify/) so handlers' relative imports of lib/ still resolve.
set -u
cd "$(dirname "$0")/.."
if [ ! -x node_modules/.bin/vitest ]; then
  echo "SKIPPED: node_modules missing, run npm install"
  exit 1
fi
fail=0
export HTMXLINGS_TIMEOUT=6000
report=$(mktemp)
trap 'rm -rf "$report" .verify' EXIT

# Per test file: "passed" when every assertion passed, else "failed".
summarise() {
  node -e '
    const r = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
    for (const t of r.testResults) {
      const ok = t.status === "passed" && t.assertionResults.length > 0 &&
        t.assertionResults.every((a) => a.status === "passed");
      console.log(require("path").relative(process.cwd(), t.name), ok ? "passed" : "failed");
    }' "$report"
}

echo "== solutions"
HTMXLINGS_SRC=solutions node_modules/.bin/vitest run --reporter=json --outputFile="$report" >/dev/null 2>&1
n=0
while read -r file status; do
  n=$((n + 1))
  if [ "$status" != passed ]; then echo "SOLUTION FAILS: $file"; fail=1; fi
done < <(summarise)
total=$(find tests -name '*.test.js' | wc -l)
[ "$n" -eq "$total" ] || { echo "only $n of $total test files reported"; fail=1; }
echo "$n test files run against solutions/"

echo "== exercises (untouched)"
rm -rf .verify && cp -r exercises .verify
HTMXLINGS_SRC=.verify node_modules/.bin/vitest run --reporter=json --outputFile="$report" >/dev/null 2>&1
while read -r file status; do
  if [ "$status" = passed ]; then echo "EXERCISE NOT BROKEN: $file"; fail=1; fi
done < <(summarise)

[ $fail -eq 0 ] && echo "ALL GOOD"
exit $fail

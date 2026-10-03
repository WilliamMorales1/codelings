#!/usr/bin/env bash
# Verify every solution passes its tests, and every untouched exercise fails them.
set -u
cd "$(dirname "$0")/.."

if [ ! -x node_modules/.bin/vitest ]; then
  echo "SKIPPED: node_modules missing, run npm install"
  exit 1
fi

skip=()
if ! node -e "require('node:sqlite')" 2>/dev/null; then
  echo "SKIPPED 05_sqlite: this node has no node:sqlite"
  skip+=(05_sqlite)
fi

work=.weblings-tmp
rm -rf "$work"
mkdir -p "$work"
trap 'rm -rf "$work"' EXIT

# The copy must live inside the project so bare imports (react, vite) still resolve.
cp -r exercises "$work/exercises"

specs=$(find tests -path tests/fixtures -prune -o -name '*.test.js*' -print | sort)
for s in "${skip[@]:-}"; do [ -n "$s" ] && specs=$(echo "$specs" | grep -v "tests/$s/"); done

run() { # $1 = source dir, $2 = report file
  WEBLINGS_SRC="$1" NO_COLOR=1 node node_modules/vitest/vitest.mjs run \
    --reporter=json --outputFile="$2" $specs > "$2.log" 2>&1
}

run solutions "$work/solutions.json"
run "$work/exercises" "$work/exercises.json"

node - "$work" $specs <<'JS'
const fs = require('node:fs');
const path = require('node:path');
const [work, ...specs] = process.argv.slice(2);
const load = (f) => {
  try {
    const j = JSON.parse(fs.readFileSync(path.join(work, f), 'utf8'));
    return new Map(j.testResults.map((r) => [path.relative(process.cwd(), r.name), r]));
  } catch {
    console.log(`vitest produced no report for ${f}:`);
    console.log(fs.readFileSync(path.join(work, f + '.log'), 'utf8').slice(0, 2000));
    process.exit(1);
  }
};
const passed = (r) => !!r && r.status === 'passed' && r.assertionResults.length > 0 && r.assertionResults.every((a) => a.status === 'passed');
const sol = load('solutions.json');
const ex = load('exercises.json');
let fail = 0;
for (const spec of specs) {
  const s = sol.get(spec);
  if (!passed(s)) {
    fail = 1;
    console.log(`SOLUTION BROKEN: ${spec}`);
    const msgs = [s?.message, ...(s?.assertionResults ?? []).flatMap((a) => a.failureMessages)].filter(Boolean);
    console.log('    ' + (msgs[0] ?? 'no result').split('\n').slice(0, 6).join('\n    '));
  }
  if (passed(ex.get(spec))) {
    fail = 1;
    console.log(`EXERCISE NOT BROKEN: ${spec}`);
  }
}
console.log(`${specs.length} specs checked`);
if (fail) process.exit(1);
JS
status=$?

if ! diff -rq exercises .templates > /dev/null; then
  echo "WARNING: exercises/ differs from .templates/"
  diff -rq exercises .templates | head
fi

[ $status -eq 0 ] && echo "ALL GOOD"
exit $status

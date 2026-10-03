import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { discover, listFiles } from '../runner/exercises.js';

const root = path.resolve(import.meta.dirname, '..');
const filter = process.argv[2];
const exs = discover(root).filter((e) => !filter || e.chapter.startsWith(filter) || e.name === filter);
let bad = 0;
const fail = (msg) => {
  bad++;
  console.log(`FAIL  ${msg}`);
};

for (const ex of exs) {
  if (!ex.path) fail(`${ex.id}: no exercise`);
  if (!ex.solution) fail(`${ex.id}: no solution`);
  if (!ex.template) fail(`${ex.id}: no .templates copy`);
  if (ex.path && ex.template) {
    const a = listFiles(ex.path).map((f) => fs.readFileSync(f, 'utf8')).join('\0');
    const b = listFiles(ex.template).map((f) => fs.readFileSync(f, 'utf8')).join('\0');
    if (a !== b) console.log(`note  ${ex.id}: exercises/ differs from .templates/ (edited?)`);
  }
}

function runVitest(src) {
  const out = path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'tailwindlings-report-')), 'r.json');
  spawnSync(process.execPath, [path.join(root, 'node_modules/vitest/vitest.mjs'), 'run', '--reporter=json', `--outputFile=${out}`, ...exs.map((e) => e.testRel)], {
    cwd: root,
    env: { ...process.env, TAILWINDLINGS_SRC: src, NO_COLOR: '1' },
    stdio: 'ignore',
  });
  const json = JSON.parse(fs.readFileSync(out, 'utf8'));
  fs.rmSync(path.dirname(out), { recursive: true, force: true });
  return new Map(json.testResults.map((r) => [path.resolve(r.name), r]));
}

const passed = (r) => !!r && r.status === 'passed' && r.assertionResults.length > 0 && r.assertionResults.every((a) => a.status === 'passed');

const sol = runVitest(path.join(root, 'solutions'));
const exr = runVitest(path.join(root, 'exercises'));

for (const ex of exs) {
  const s = passed(sol.get(ex.test));
  const e = passed(exr.get(ex.test));
  if (!s) {
    const why = (sol.get(ex.test)?.assertionResults ?? []).filter((a) => a.status !== 'passed').map((a) => `${a.title}: ${(a.failureMessages ?? [])[0]?.split('\n')[0]}`);
    fail(`${ex.id}: solution does not pass\n      ${why.join('\n      ') || sol.get(ex.test)?.message || 'no results'}`);
  } else if (e) fail(`${ex.id}: untouched exercise already passes`);
  else console.log(`ok    ${ex.id}`);
}
console.log(bad ? `\n${bad} problem(s)` : `\nall ${exs.length} exercises verified`);
process.exitCode = bad ? 1 : 0;

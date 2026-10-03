import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

function vitestBin(root) {
  const bin = path.join(root, 'node_modules', 'vitest', 'vitest.mjs');
  if (!fs.existsSync(bin)) throw new Error('vitest is not installed; run `npm install` first');
  return bin;
}

function childEnv() {
  const env = { ...process.env };
  if (env.NO_COLOR !== undefined) delete env.FORCE_COLOR;
  else if (process.stdout.isTTY) env.FORCE_COLOR = '1';
  return env;
}

function exec(root, args) {
  return new Promise((resolve) => {
    const child = spawn(process.execPath, [vitestBin(root), ...args], {
      cwd: root,
      env: childEnv(),
      stdio: ['ignore', 'pipe', 'pipe'],
    });
    let out = '';
    child.stdout.on('data', (d) => (out += d));
    child.stderr.on('data', (d) => (out += d));
    child.on('close', (code) => resolve({ code, out }));
  });
}

/** runBatch runs every given exercise's test in one vitest process; returns Map id -> passed. */
export async function runBatch(root, exs) {
  const results = new Map();
  if (exs.length === 0) return results;
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'tailwindlings-'));
  const report = path.join(tmp, 'report.json');
  try {
    const { out } = await exec(root, ['run', '--reporter=json', `--outputFile=${report}`, ...exs.map((e) => e.testRel)]);
    let json = null;
    try {
      json = JSON.parse(fs.readFileSync(report, 'utf8'));
    } catch {
      // vitest died before reporting (bad config, missing deps): everything counts as failed.
    }
    const byFile = new Map((json?.testResults ?? []).map((r) => [path.resolve(r.name), r]));
    for (const ex of exs) {
      const r = byFile.get(ex.test);
      const passed =
        !!r && r.status === 'passed' && r.assertionResults.length > 0 &&
        r.assertionResults.every((a) => a.status === 'passed');
      results.set(ex.id, { passed, fallback: json ? null : out });
    }
  } finally {
    fs.rmSync(tmp, { recursive: true, force: true });
  }
  return results;
}

// Vitest's banner and timing lines are noise when the learner only cares about one file.
const NOISE = /^\s*(RUN\s+v\d|Start at|Duration|Transform|Environment)\b/;

function tidy(text) {
  return text
    .split('\n')
    .filter((l) => !NOISE.test(l.replace(/\x1b\[[0-9;]*m/g, '')))
    .join('\n')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

/** runOne runs a single exercise's test with the human-readable reporter. */
export async function runOne(root, ex) {
  const { code, out } = await exec(root, ['run', '--reporter=default', ex.testRel]);
  return { passed: code === 0, output: tidy(out) };
}

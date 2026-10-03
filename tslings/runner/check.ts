import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { exerciseFiles, srcDir, type Exercise } from './exercises.ts';
import { fileLink, paint } from './ui.ts';

export interface Diagnostic {
  /** Absolute path, or null for errors that belong to no file (bad config). */
  file: string | null;
  line: number;
  col: number;
  code: string;
  message: string;
}

export interface TestResult {
  passed: boolean;
  /** Raw output, set only when vitest died before writing its report. */
  fallback: string | null;
}

function bin(root: string, rel: string, pkg: string): string {
  const p = path.join(root, 'node_modules', rel);
  if (!fs.existsSync(p)) throw new Error(`${pkg} is not installed; run \`npm install\` first`);
  return p;
}

function childEnv(): NodeJS.ProcessEnv {
  const env = { ...process.env };
  if (env.NO_COLOR !== undefined) delete env.FORCE_COLOR;
  else if (process.stdout.isTTY) env.FORCE_COLOR = '1';
  return env;
}

function exec(root: string, script: string, args: string[]): Promise<{ code: number | null; out: string }> {
  return new Promise((resolve) => {
    const child = spawn(process.execPath, [script, ...args], { cwd: root, env: childEnv(), stdio: ['ignore', 'pipe', 'pipe'] });
    let out = '';
    child.stdout.on('data', (d: Buffer) => (out += d.toString()));
    child.stderr.on('data', (d: Buffer) => (out += d.toString()));
    child.on('close', (code) => resolve({ code, out }));
  });
}

const DIAG_RE = /^(.+?)\((\d+),(\d+)\): error (TS\d+): (.*)$/;
const GLOBAL_RE = /^error (TS\d+): (.*)$/;

function parseTsc(root: string, out: string): Diagnostic[] {
  const diags: Diagnostic[] = [];
  for (const line of out.split('\n')) {
    const m = line.match(DIAG_RE);
    const g = m ? null : line.match(GLOBAL_RE);
    if (m) {
      diags.push({ file: path.resolve(root, m[1]!), line: Number(m[2]), col: Number(m[3]), code: m[4]!, message: m[5]! });
    } else if (g) {
      diags.push({ file: null, line: 0, col: 0, code: g[1]!, message: g[2]! });
    } else if (line.trim() && diags.length > 0) {
      // Follow-up lines of an elaborated message ("Type 'x' is not assignable ...").
      diags[diags.length - 1]!.message += '\n' + line.replace(/\s+$/, '');
    }
  }
  return diags;
}

const owns = (ex: Exercise, file: string): boolean =>
  file === ex.test || (ex.path !== null && (file === ex.path || file.startsWith(ex.path + path.sep)));

/**
 * typecheck runs one tsc process over the given exercises and their tests, using the
 * course tsconfig.json; returns Map id -> diagnostics (empty when the exercise is clean).
 */
export async function typecheck(root: string, exs: Exercise[]): Promise<Map<string, Diagnostic[]>> {
  const result = new Map<string, Diagnostic[]>(exs.map((e) => [e.id, []]));
  if (exs.length === 0) return result;
  const files = exs.flatMap((e) => [...exerciseFiles(e).filter((f) => f.endsWith('.ts')), e.test]);
  // Inside the project, not /tmp: tsc looks up `types` from the config's directory upwards.
  const cacheDir = path.join(root, 'node_modules', '.cache');
  fs.mkdirSync(cacheDir, { recursive: true });
  const tmp = fs.mkdtempSync(path.join(cacheDir, 'tslings-'));
  const config = path.join(tmp, 'tsconfig.json');
  fs.writeFileSync(
    config,
    JSON.stringify({
      extends: path.join(root, 'tsconfig.json'),
      compilerOptions: { paths: { '@ex/*': [path.join(srcDir(root), '*')] } },
      files,
      include: [],
    }),
  );
  try {
    const { code, out } = await exec(root, bin(root, 'typescript/bin/tsc', 'typescript'), ['-p', config, '--pretty', 'false']);
    const diags = parseTsc(root, out);
    if (code !== 0 && diags.length === 0) diags.push({ file: null, line: 0, col: 0, code: 'tsc', message: out.trim() || `tsc exited with ${code}` });
    for (const d of diags) {
      const owners = d.file ? exs.filter((e) => owns(e, d.file!)) : [];
      // An error in no exercise's files (config, shared helper) fails everything it touched.
      for (const e of owners.length ? owners : exs) result.get(e.id)!.push(d);
    }
  } finally {
    fs.rmSync(tmp, { recursive: true, force: true });
  }
  return result;
}

/** formatDiagnostics renders tsc errors with a one-line code frame each. */
export function formatDiagnostics(root: string, diags: Diagnostic[]): string {
  const cache = new Map<string, string[]>();
  const src = (f: string): string[] => {
    if (!cache.has(f)) {
      try {
        cache.set(f, fs.readFileSync(f, 'utf8').split('\n'));
      } catch {
        cache.set(f, []);
      }
    }
    return cache.get(f)!;
  };
  return diags
    .map((d) => {
      if (!d.file) return `${paint('red', `error ${d.code}`)}: ${d.message}`;
      const rel = path.relative(root, d.file);
      const head = `${fileLink(d.file, `${rel}:${d.line}:${d.col}`, d.line)} ${paint('red', `error ${d.code}`)}: ${d.message}`;
      const text = src(d.file)[d.line - 1];
      if (text === undefined) return head;
      const num = String(d.line);
      const gutter = ' '.repeat(num.length);
      const caret = text.slice(0, d.col - 1).replace(/[^\t]/g, ' ') + paint('red', '^');
      return `${head}\n  ${paint('dim', `${num} |`)} ${text}\n  ${paint('dim', `${gutter} |`)} ${caret}`;
    })
    .join('\n\n');
}

/** runBatch runs every given exercise's test in one vitest process; returns Map id -> result. */
export async function runBatch(root: string, exs: Exercise[]): Promise<Map<string, TestResult>> {
  const results = new Map<string, TestResult>();
  if (exs.length === 0) return results;
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'tslings-'));
  const report = path.join(tmp, 'report.json');
  try {
    const vitest = bin(root, 'vitest/vitest.mjs', 'vitest');
    const { out } = await exec(root, vitest, ['run', '--reporter=json', `--outputFile=${report}`, ...exs.map((e) => e.testRel)]);
    let json: VitestReport | null = null;
    try {
      json = JSON.parse(fs.readFileSync(report, 'utf8')) as VitestReport;
    } catch {
      // vitest died before reporting (bad config, missing deps): everything counts as failed.
    }
    const byFile = new Map((json?.testResults ?? []).map((r) => [path.resolve(r.name), r]));
    for (const ex of exs) {
      const r = byFile.get(ex.test);
      const passed =
        !!r && r.status === 'passed' && r.assertionResults.length > 0 && r.assertionResults.every((a) => a.status === 'passed');
      results.set(ex.id, { passed, fallback: json ? null : out });
    }
  } finally {
    fs.rmSync(tmp, { recursive: true, force: true });
  }
  return results;
}

interface VitestReport {
  testResults: { name: string; status: string; assertionResults: { status: string }[] }[];
}

// Vitest's banner and timing lines are noise when the learner only cares about one file.
const NOISE = /^\s*(RUN\s+v\d|Start at|Duration|Transform|Environment)\b/;

function tidy(text: string): string {
  return text
    .split('\n')
    .filter((l) => !NOISE.test(l.replace(/\x1b\[[0-9;]*m/g, '')))
    .join('\n')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

/** runOne runs a single exercise's test with the human-readable reporter. */
export async function runOne(root: string, ex: Exercise): Promise<{ passed: boolean; output: string }> {
  const { code, out } = await exec(root, bin(root, 'vitest/vitest.mjs', 'vitest'), ['run', '--reporter=default', ex.testRel]);
  return { passed: code === 0, output: tidy(out) };
}

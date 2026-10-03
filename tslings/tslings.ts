#!/usr/bin/env node
// tslings: small exercises for TypeScript's type system, in the spirit of rustlings.
import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';
import { formatDiagnostics, runBatch, runOne, typecheck } from './runner/check.ts';
import { discover, exerciseFiles, find, findRoot, hint, listFiles, loadProgress, stamp, type Exercise } from './runner/exercises.ts';
import { clearScreen, fileLink, indent, padTo, paint, progressBar, say } from './runner/ui.ts';

type Outcome =
  | { status: 'failed'; stage: 'missing' | 'types' | 'tests'; output: string | null }
  | { status: 'passed' };

type Cache = Map<string, { stamp: string; outcome: Outcome }>;

const root = findRoot();
const rel = (p: string): string => path.relative(root, p);
const link = (p: string): string => fileLink(p, rel(p));
const progress = loadProgress(root);

/** check typechecks, then tests, the given exercises: one tsc and one vitest process for the whole batch. */
async function check(exs: Exercise[]): Promise<Map<string, Outcome>> {
  const out = new Map<string, Outcome>();
  const types = await typecheck(root, exs);
  const typed: Exercise[] = [];
  for (const ex of exs) {
    const diags = types.get(ex.id)!;
    if (diags.length) out.set(ex.id, { status: 'failed', stage: 'types', output: formatDiagnostics(root, diags) });
    else typed.push(ex);
  }
  const tests = await runBatch(root, typed);
  for (const ex of typed) {
    const r = tests.get(ex.id)!;
    out.set(ex.id, r.passed ? { status: 'passed' } : { status: 'failed', stage: 'tests', output: r.fallback });
  }
  return out;
}

/** checkAll returns an outcome for every exercise, re-checking only those not already passed or in `cache` with the same stamp. */
async function checkAll(exs: Exercise[], cache: Cache = new Map()): Promise<Map<string, Outcome>> {
  const outcomes = new Map<string, Outcome>();
  const toRun: Exercise[] = [];
  const stamps = new Map<string, string>();
  for (const ex of exs) {
    if (!ex.path) {
      outcomes.set(ex.id, { status: 'failed', stage: 'missing', output: `exercise is missing; try \`tslings reset ${ex.name}\`` });
      continue;
    }
    const st = stamp(ex);
    stamps.set(ex.id, st);
    if (progress.done(ex, st)) {
      outcomes.set(ex.id, { status: 'passed' });
      continue;
    }
    const hit = cache.get(ex.id);
    if (hit && hit.stamp === st) outcomes.set(ex.id, hit.outcome);
    else toRun.push(ex);
  }
  const results = await check(toRun);
  for (const ex of toRun) {
    const outcome = results.get(ex.id)!;
    outcomes.set(ex.id, outcome);
    cache.set(ex.id, { stamp: stamps.get(ex.id)!, outcome });
    progress.record(ex, stamps.get(ex.id)!, outcome.status === 'passed');
  }
  progress.save();
  return outcomes;
}

async function withOutput(ex: Exercise, o: Outcome): Promise<Outcome> {
  if (o.status === 'failed' && o.stage === 'tests' && o.output == null) {
    return { ...o, output: (await runOne(root, ex)).output };
  }
  return o;
}

function showHint(ex: Exercise): void {
  const h = hint(ex);
  if (!h) return say('dim', '(this exercise has no hint)');
  say('cyan', 'Hint:');
  console.log(indent(h));
}

/** report prints one outcome; returns true when the learner may move on. */
function report(ex: Exercise, o: Outcome): boolean {
  if (o.status === 'failed') {
    const what = { missing: 'is missing', types: 'does not typecheck', tests: 'fails its tests' }[o.stage];
    say('red', `x ${ex.id} ${what}.`);
    if (ex.path) console.log(`  File: ${link(ex.path)}`);
    console.log(`  Test: ${link(ex.test)}`);
    if (o.output) console.log('\n' + indent(o.output));
    console.log('');
    showHint(ex);
    return false;
  }
  say('green', `v ${ex.id} passes!`);
  return true;
}

async function verify(exs: Exercise[], cache?: Cache): Promise<number> {
  const outcomes = await checkAll(exs, cache);
  const idx = exs.findIndex((e) => outcomes.get(e.id)!.status !== 'passed');
  if (idx === -1) {
    say('green', `All ${exs.length} exercises complete. You can now type anything.`);
    return 0;
  }
  const ex = exs[idx]!;
  const o = await withOutput(ex, outcomes.get(ex.id)!);
  console.log(progressBar(idx, exs.length));
  console.log('');
  report(ex, o);
  return 1;
}

async function cmdList(exs: Exercise[]): Promise<number> {
  const outcomes = await checkAll(exs);
  const labels = { failed: ['yellow', 'PENDING'], passed: ['green', 'DONE   '] } as const;
  let done = 0;
  for (const ex of exs) {
    const o = outcomes.get(ex.id)!;
    if (o.status === 'passed') done++;
    const [style, label] = labels[o.status];
    console.log(`${paint(style, label)}  ${padTo(ex.id, 36)} ${ex.path ? link(ex.path) : ''}`);
  }
  console.log('');
  console.log(progressBar(done, exs.length));
  return 0;
}

function target(exs: Exercise[], name: string): Exercise {
  const ex = find(exs, name);
  if (!ex) throw new Error(`no exercise named \`${name}\` (try \`tslings list\`)`);
  return ex;
}

async function nextUnsolved(exs: Exercise[]): Promise<Exercise | undefined> {
  const outcomes = await checkAll(exs);
  return exs.find((e) => outcomes.get(e.id)!.status !== 'passed');
}

async function cmdRun(exs: Exercise[], name?: string): Promise<number> {
  const ex = name ? target(exs, name) : await nextUnsolved(exs);
  if (!ex) {
    say('green', 'Nothing left to run: every exercise passes.');
    return 0;
  }
  if (!ex.path) return report(ex, (await checkAll([ex])).get(ex.id)!) ? 0 : 1;
  const o = (await check([ex])).get(ex.id)!;
  progress.record(ex, stamp(ex), o.status === 'passed');
  progress.save();
  return report(ex, await withOutput(ex, o)) ? 0 : 1;
}

async function cmdHint(exs: Exercise[], name?: string): Promise<number> {
  const ex = name ? target(exs, name) : await nextUnsolved(exs);
  if (!ex) throw new Error('every exercise already passes');
  say('bold', ex.id);
  showHint(ex);
  return 0;
}

function cmdSolution(exs: Exercise[], name: string): number {
  const ex = target(exs, name);
  if (!ex.solution) {
    say('yellow', `no solution for ${ex.id}`);
    return 1;
  }
  say('bold', `Solution for ${ex.id}:`);
  for (const f of listFiles(ex.solution)) {
    console.log('');
    say('cyan', `--- ${rel(f)}`);
    console.log(fs.readFileSync(f, 'utf8').replace(/\s+$/, ''));
  }
  return 0;
}

function cmdReset(exs: Exercise[], name: string): number {
  const ex = target(exs, name);
  if (!ex.template) throw new Error(`no pristine copy of ${ex.id} in .templates/`);
  const dest = path.join(root, 'exercises', ex.chapter, path.basename(ex.template));
  if (ex.path) fs.rmSync(ex.path, { recursive: true, force: true });
  fs.cpSync(ex.template, dest, { recursive: true });
  say('yellow', `reset ${ex.id} to its original state`);
  return 0;
}

async function cmdWatch(filter?: string): Promise<never> {
  const cache: Cache = new Map();
  let last: string | null = null;
  for (;;) {
    let exs = discover(root);
    if (filter) exs = exs.filter((e) => e.chapter.startsWith(filter) || e.chapter.slice(3).startsWith(filter));
    if (exs.length === 0) throw new Error(`no chapter matches \`${filter}\``);
    const key = exs.map(stamp).join('\n') + exs.map((e) => exerciseFiles(e).length).join();
    if (key !== last) {
      last = key;
      clearScreen();
      say('bold', `tslings watch${filter ? ` (${filter})` : ''}`);
      await verify(exs, cache);
      console.log('');
      say('dim', 'watching... save a file to re-check, Ctrl-C to quit');
    }
    await new Promise((r) => setTimeout(r, 700));
  }
}

function cmdDoctor(): number {
  let ok = true;
  const line = (good: boolean, what: string, fix: string): void => {
    if (!good) ok = false;
    console.log(`${good ? paint('green', 'ok     ') : paint('red', 'missing')}  ${padTo(what, 40)}${good ? '' : paint('dim', fix)}`);
  };
  const [major = 0, minor = 0] = process.versions.node.split('.').map(Number);
  // Running tslings.ts directly relies on type stripping being on by default (22.18+, 23.6+).
  line(major > 23 || (major === 23 && minor >= 6) || (major === 22 && minor >= 18), `node >= 22.18 (have ${process.versions.node})`, 'install Node.js (see README Setup)');
  const require = createRequire(path.join(root, 'package.json'));
  for (const [pkg, want] of [['typescript', 7], ['vitest', 4], ['@types/node', 0]] as const) {
    let version: string | null = null;
    try {
      version = (require(`${pkg}/package.json`) as { version: string }).version;
    } catch {}
    const good = version !== null && Number(version.split('.')[0]) >= want;
    line(good, `${pkg}${want ? ` >= ${want}` : ''}${version ? ` (have ${version})` : ''}`, 'npm install');
  }
  return ok ? 0 : 1;
}

const USAGE = `tslings - small TypeScript exercises, in the spirit of rustlings

USAGE:
    node tslings.ts [COMMAND]

COMMANDS:
    verify              Check exercises in order, stopping at the first unsolved one (default)
    watch [CHAPTER]     Same as verify, but re-checks every time you save (optionally one chapter: 06, type_level)
    run [NAME]          Typecheck and test one exercise (defaults to the next unsolved one)
    hint [NAME]         Print the hint for an exercise
    list                Show every exercise and its status
    solution NAME       Print the reference solution
    reset NAME          Restore an exercise to its original, unsolved state
    doctor              Check that the tools the course needs are installed
    help                Show this message

An exercise passes when it typechecks under the strict tsconfig.json AND its
vitest file in tests/ passes; it is then marked done automatically and
tslings moves you on to the next one.`;

async function main(argv: string[]): Promise<number> {
  const [cmd = 'verify', arg, ...rest] = argv;
  const need = (): string => {
    if (!arg) throw new Error(`\`${cmd}\` needs an exercise name`);
    return arg;
  };
  if (rest.length) {
    console.log(USAGE);
    return 2;
  }
  switch (cmd) {
    case 'verify': return verify(discover(root));
    case 'watch': return cmdWatch(arg);
    case 'run': return cmdRun(discover(root), arg);
    case 'hint': return cmdHint(discover(root), arg);
    case 'list': return cmdList(discover(root));
    case 'solution': return cmdSolution(discover(root), need());
    case 'reset': return cmdReset(discover(root), need());
    case 'doctor': return cmdDoctor();
    case 'help': case '--help': case '-h': console.log(USAGE); return 0;
    default: console.log(USAGE); return 2;
  }
}

try {
  process.exitCode = await main(process.argv.slice(2));
} catch (e) {
  say('red', `error: ${(e as Error).message}`);
  process.exitCode = 1;
}

#!/usr/bin/env node
// weblings: small exercises for Node.js, React, Vite, Postgres and SQLite, in the spirit of rustlings.
import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';
import { execFileSync } from 'node:child_process';
import { discover, exerciseFiles, find, findRoot, hint, listFiles, loadProgress, stamp } from './runner/exercises.js';
import { runBatch, runOne } from './runner/vitest.js';
import { clearScreen, fileLink, indent, padTo, paint, progressBar, say } from './runner/ui.js';

const root = findRoot();
const rel = (p) => path.relative(root, p);
const link = (p) => fileLink(p, rel(p));
const progress = loadProgress(root, 'weblings');

/** checkAll returns Map id -> outcome, running one vitest process for every exercise not already passed or in `cache`. */
async function checkAll(exs, cache = new Map()) {
  const outcomes = new Map();
  const toRun = [];
  const stamps = new Map();
  for (const ex of exs) {
    if (!ex.path) {
      outcomes.set(ex.id, { status: 'failed', output: `exercise is missing; try \`weblings reset ${ex.name}\`` });
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
  const results = await runBatch(root, toRun);
  for (const ex of toRun) {
    const r = results.get(ex.id);
    const outcome = { status: r.passed ? 'passed' : 'failed', output: r.fallback ?? null };
    outcomes.set(ex.id, outcome);
    cache.set(ex.id, { stamp: stamps.get(ex.id), outcome });
    progress.record(ex, stamps.get(ex.id), r.passed);
  }
  progress.save();
  return outcomes;
}

async function withOutput(ex, outcome) {
  if (outcome.status === 'failed' && outcome.output == null) {
    const r = await runOne(root, ex);
    outcome.output = r.output;
  }
  return outcome;
}

function showHint(ex) {
  const h = hint(ex);
  if (!h) return say('dim', '(this exercise has no hint)');
  say('cyan', 'Hint:');
  console.log(indent(h));
}

/** report prints one outcome; returns true when the learner may move on. */
function report(ex, o) {
  if (o.status === 'failed') {
    say('red', `x ${ex.id} fails its tests.`);
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

async function verify(exs, cache) {
  const outcomes = await checkAll(exs, cache);
  const idx = exs.findIndex((e) => outcomes.get(e.id).status !== 'passed');
  if (idx === -1) {
    say('green', `All ${exs.length} exercises complete. The web is yours.`);
    return 0;
  }
  const ex = exs[idx];
  const o = await withOutput(ex, outcomes.get(ex.id));
  console.log(progressBar(idx, exs.length));
  console.log('');
  report(ex, o);
  return 1;
}

async function cmdList(exs) {
  const outcomes = await checkAll(exs);
  const labels = { failed: ['yellow', 'PENDING'], passed: ['green', 'DONE   '] };
  let done = 0;
  for (const ex of exs) {
    const o = outcomes.get(ex.id);
    if (o.status === 'passed') done++;
    const [style, label] = labels[o.status];
    console.log(`${paint(style, label)}  ${padTo(ex.id, 30)} ${ex.path ? link(ex.path) : ''}`);
  }
  console.log('');
  console.log(progressBar(done, exs.length));
  return 0;
}

function target(exs, name) {
  const ex = find(exs, name);
  if (!ex) throw new Error(`no exercise named \`${name}\` (try \`weblings list\`)`);
  return ex;
}

async function nextUnsolved(exs) {
  const outcomes = await checkAll(exs);
  return exs.find((e) => outcomes.get(e.id).status !== 'passed');
}

async function cmdRun(exs, name) {
  const ex = name ? target(exs, name) : await nextUnsolved(exs);
  if (!ex) {
    say('green', 'Nothing left to run: every exercise passes.');
    return 0;
  }
  const r = ex.path ? await runOne(root, ex) : { passed: false, output: null };
  if (ex.path) {
    progress.record(ex, stamp(ex), r.passed);
    progress.save();
  }
  return report(ex, { status: r.passed ? 'passed' : 'failed', output: r.output }) ? 0 : 1;
}

async function cmdHint(exs, name) {
  const ex = name ? target(exs, name) : await nextUnsolved(exs);
  if (!ex) throw new Error('every exercise already passes');
  say('bold', ex.id);
  showHint(ex);
  return 0;
}

function cmdSolution(exs, name) {
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

function cmdReset(exs, name) {
  const ex = target(exs, name);
  if (!ex.template) throw new Error(`no pristine copy of ${ex.id} in .templates/`);
  const dest = path.join(root, 'exercises', ex.chapter, path.basename(ex.template));
  if (ex.path) fs.rmSync(ex.path, { recursive: true, force: true });
  fs.cpSync(ex.template, dest, { recursive: true });
  say('yellow', `reset ${ex.id} to its original state`);
  return 0;
}

async function cmdWatch(filter) {
  const cache = new Map();
  let last = null;
  for (;;) {
    let exs = discover(root);
    if (filter) exs = exs.filter((e) => e.chapter.startsWith(filter) || e.chapter.slice(3).startsWith(filter));
    if (exs.length === 0) throw new Error(`no chapter matches \`${filter}\``);
    const key = exs.map(stamp).join('\n') + exs.map((e) => exerciseFiles(e).length).join();
    if (key !== last) {
      last = key;
      clearScreen();
      say('bold', `weblings watch${filter ? ` (${filter})` : ''}`);
      await verify(exs, cache);
      console.log('');
      say('dim', 'watching... save a file to re-check, Ctrl-C to quit');
    }
    await new Promise((r) => setTimeout(r, 700));
  }
}

function cmdDoctor() {
  let ok = true;
  const line = (good, what, fix) => {
    if (!good) ok = false;
    console.log(`${good ? paint('green', 'ok     ') : paint('red', 'missing')}  ${padTo(what, 34)}${good ? '' : paint('dim', fix)}`);
  };
  const [major, minor] = process.versions.node.split('.').map(Number);
  line(major > 22 || (major === 22 && minor >= 13), `node >= 22.13 (have ${process.versions.node})`, 'install Node.js (see README Setup)');
  let npm = false;
  try {
    execFileSync('npm', ['--version'], { stdio: 'ignore' });
    npm = true;
  } catch {}
  line(npm, 'npm', 'install npm (ships with Node.js on most systems)');
  for (const pkg of ['vitest', 'vite', 'react', 'react-dom', '@testing-library/react', 'jsdom', '@electric-sql/pglite']) {
    line(fs.existsSync(path.join(root, 'node_modules', pkg, 'package.json')), pkg, 'npm install');
  }
  let sqlite = false;
  try {
    const { DatabaseSync } = createRequire(import.meta.url)('node:sqlite');
    const db = new DatabaseSync(':memory:');
    db.exec('CREATE VIRTUAL TABLE t USING fts5(x); SELECT json_extract(\'{"a":1}\', \'$.a\');');
    sqlite = true;
  } catch {}
  line(sqlite, 'node:sqlite with FTS5 + JSON', 'upgrade nodejs');
  let psql = false;
  try {
    execFileSync('psql', ['--version'], { stdio: 'ignore' });
    psql = true;
  } catch {}
  console.log(`${psql ? paint('green', 'ok     ') : paint('dim', 'absent ')}  ${padTo('psql (optional)', 34)}${psql ? '' : paint('dim', 'install the PostgreSQL client (psql)')}`);
  return ok ? 0 : 1;
}

const USAGE = `weblings - small Node.js, React, Vite, Postgres and SQLite exercises, in the spirit of rustlings

USAGE:
    node weblings.js [COMMAND]

COMMANDS:
    verify              Check exercises in order, stopping at the first unsolved one (default)
    watch [CHAPTER]     Same as verify, but re-checks every time you save (optionally one chapter: 02, react)
    run [NAME]          Run one exercise's tests (defaults to the next unsolved one)
    hint [NAME]         Print the hint for an exercise
    list                Show every exercise and its status
    solution NAME       Print the reference solution
    reset NAME          Restore an exercise to its original, unsolved state
    doctor              Check that the tools the course needs are installed
    help                Show this message

Make an exercise's tests pass and save: it is marked done automatically and
weblings moves you on to the next one.`;

async function main(argv) {
  const [cmd = 'verify', arg, ...rest] = argv;
  const need = () => {
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
  say('red', `error: ${e.message}`);
  process.exitCode = 1;
}

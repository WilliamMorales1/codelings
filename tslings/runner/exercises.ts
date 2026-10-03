import fs from 'node:fs';
import path from 'node:path';

const TEST_RE = /^(.+)\.test\.ts$/;

export interface Exercise {
  chapter: string;
  name: string;
  /** `chapter/name`, unique across the course. */
  id: string;
  test: string;
  testRel: string;
  /** Exercise file or directory, or null when it has gone missing. */
  path: string | null;
  solution: string | null;
  template: string | null;
}

const natural = (a: string, b: string): number => a.localeCompare(b, 'en', { numeric: true });

/** findRoot walks up from the cwd to the first directory holding both `exercises/` and `tests/`. */
export function findRoot(start = process.cwd()): string {
  let dir = path.resolve(start);
  for (;;) {
    if (fs.existsSync(path.join(dir, 'exercises')) && fs.existsSync(path.join(dir, 'tests'))) return dir;
    const up = path.dirname(dir);
    if (up === dir) throw new Error('could not find an `exercises/` directory; run tslings from inside the course');
    dir = up;
  }
}

/** srcDir is where exercises are read from: `exercises/`, or TSLINGS_SRC (used by verify-all). */
export const srcDir = (root: string): string => path.resolve(root, process.env.TSLINGS_SRC ?? 'exercises');

/** listFiles returns every file under `p` (or `p` itself), sorted. */
export function listFiles(p: string): string[] {
  let st: fs.Stats;
  try {
    st = fs.statSync(p);
  } catch {
    return [];
  }
  if (!st.isDirectory()) return [p];
  return fs
    .readdirSync(p)
    .sort(natural)
    .flatMap((name) => listFiles(path.join(p, name)));
}

// An exercise is `name.ts` or a directory `name/` inside its chapter.
function locate(dir: string, name: string): string | null {
  if (!fs.existsSync(dir)) return null;
  const hit = fs
    .readdirSync(dir, { withFileTypes: true })
    .find((e) => e.name === name || (e.isFile() && e.name.startsWith(name + '.')));
  return hit ? path.join(dir, hit.name) : null;
}

/** discover returns all exercises in curriculum order, driven by the files in tests/. */
export function discover(root: string): Exercise[] {
  const testsDir = path.join(root, 'tests');
  const src = srcDir(root);
  const chapters = fs
    .readdirSync(testsDir, { withFileTypes: true })
    .filter((e) => e.isDirectory() && /^\d+_/.test(e.name))
    .map((e) => e.name)
    .sort(natural);
  const out: Exercise[] = [];
  for (const chapter of chapters) {
    const names = fs
      .readdirSync(path.join(testsDir, chapter))
      .flatMap((f) => f.match(TEST_RE)?.[1] ?? [])
      .sort(natural);
    for (const name of names) {
      const test = path.join(testsDir, chapter, `${name}.test.ts`);
      out.push({
        chapter,
        name,
        id: `${chapter}/${name}`,
        test,
        testRel: path.relative(root, test),
        path: locate(path.join(src, chapter), name),
        solution: locate(path.join(root, 'solutions', chapter), name),
        template: locate(path.join(root, '.templates', chapter), name),
      });
    }
  }
  return out;
}

export const exerciseFiles = (ex: Exercise): string[] => (ex.path ? listFiles(ex.path) : []);

export interface Progress {
  done(ex: Exercise, st: string): boolean;
  record(ex: Exercise, st: string, ok: boolean): void;
  save(): void;
}

/** loadProgress remembers passing exercises by stamp, so editing a solved one puts it back in the queue. */
export function loadProgress(root: string): Progress {
  const file = path.join(root, '.tslings-progress.json');
  let passed: Record<string, string> = {};
  try {
    passed = JSON.parse(fs.readFileSync(file, 'utf8')) as Record<string, string>;
  } catch {}
  return {
    done: (ex, st) => passed[ex.id] === st,
    record(ex, st, ok) {
      if (ok) passed[ex.id] = st;
      else delete passed[ex.id];
    },
    save() {
      // TSLINGS_SRC points the runner at solutions/ or a scratch copy; that must not touch real progress.
      if (process.env.TSLINGS_SRC) return;
      try {
        fs.writeFileSync(file, JSON.stringify(passed, null, 2) + '\n');
      } catch {}
    },
  };
}

/** stamp is a cheap change token: mtime and size of every exercise file plus the test. */
export function stamp(ex: Exercise): string {
  return [...exerciseFiles(ex), ex.test]
    .map((f) => {
      try {
        const s = fs.statSync(f);
        return `${f}:${s.mtimeMs}:${s.size}`;
      } catch {
        return `${f}:gone`;
      }
    })
    .join('|');
}

/** hint returns the text of the test file's HINT block, or null. */
export function hint(ex: Exercise): string | null {
  const m = fs.readFileSync(ex.test, 'utf8').match(/\/\*\s*HINT\b([\s\S]*?)\*\//);
  if (!m?.[1]) return null;
  const lines = m[1].replace(/^\n+|\s+$/g, '').split('\n');
  const pad = Math.min(...lines.filter((l) => l.trim()).map((l) => l.match(/^ */)?.[0].length ?? 0));
  return lines.map((l) => l.slice(pad)).join('\n');
}

/** find matches a user-typed name against `name`, `chapter/name` or a path. */
export function find(exs: Exercise[], needle: string): Exercise | undefined {
  const n = needle.replace(/\/+$/, '').replace(/\.test\.ts$/, '').replace(/\.(ts|d\.ts|js)$/, '');
  return exs.find(
    (e) => e.name === n || e.id === n || `exercises/${e.id}` === n || `tests/${e.id}` === n || e.path === path.resolve(needle),
  );
}

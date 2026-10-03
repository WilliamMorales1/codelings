import fs from 'node:fs';
import path from 'node:path';

const SKIP_DIRS = new Set(['node_modules', 'dist', '.vite']);
const TEST_RE = /^(.+)\.test\.(js|jsx|mjs)$/;

const natural = (a, b) => a.localeCompare(b, 'en', { numeric: true });

/** findRoot walks up from the cwd to the first directory that holds `exercises/`. */
export function findRoot(start = process.cwd()) {
  let dir = path.resolve(start);
  for (;;) {
    if (fs.existsSync(path.join(dir, 'exercises')) && fs.existsSync(path.join(dir, 'tests'))) return dir;
    const up = path.dirname(dir);
    if (up === dir) throw new Error('could not find an `exercises/` directory; run weblings from inside the course');
    dir = up;
  }
}

/** listFiles returns every file under `p` (or `p` itself), sorted, skipping build output. */
export function listFiles(p) {
  let st;
  try {
    st = fs.statSync(p);
  } catch {
    return [];
  }
  if (!st.isDirectory()) return [p];
  const out = [];
  for (const entry of fs.readdirSync(p, { withFileTypes: true }).sort((a, b) => natural(a.name, b.name))) {
    if (entry.isDirectory() && SKIP_DIRS.has(entry.name)) continue;
    out.push(...listFiles(path.join(p, entry.name)));
  }
  return out;
}

// An exercise is `name.<ext>` or a directory `name/` inside its chapter.
function locate(dir, name) {
  if (!fs.existsSync(dir)) return null;
  const hit = fs
    .readdirSync(dir, { withFileTypes: true })
    .find((e) => e.name === name || (e.isFile() && e.name.startsWith(name + '.')));
  return hit ? path.join(dir, hit.name) : null;
}

/** discover returns all exercises in curriculum order, driven by the files in tests/. */
export function discover(root) {
  const testsDir = path.join(root, 'tests');
  const chapters = fs
    .readdirSync(testsDir, { withFileTypes: true })
    .filter((e) => e.isDirectory() && /^\d+_/.test(e.name))
    .map((e) => e.name)
    .sort(natural);
  const out = [];
  for (const chapter of chapters) {
    const specs = fs
      .readdirSync(path.join(testsDir, chapter))
      .map((f) => f.match(TEST_RE))
      .filter(Boolean)
      .sort((a, b) => natural(a[1], b[1]));
    for (const [file, name] of specs) {
      const test = path.join(testsDir, chapter, file);
      const target = locate(path.join(root, 'exercises', chapter), name);
      out.push({
        chapter,
        name,
        id: `${chapter}/${name}`,
        test,
        testRel: path.relative(root, test),
        path: target,
        isDir: target ? fs.statSync(target).isDirectory() : false,
        solution: locate(path.join(root, 'solutions', chapter), name),
        template: locate(path.join(root, '.templates', chapter), name),
      });
    }
  }
  return out;
}

export const exerciseFiles = (ex) => (ex.path ? listFiles(ex.path) : []);

/** loadProgress remembers passing exercises by stamp, so editing a solved one puts it back in the queue. */
export function loadProgress(root, course) {
  const file = path.join(root, `.${course}-progress.json`);
  let passed = {};
  try {
    passed = JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch {}
  return {
    done: (ex, st) => passed[ex.id] === st,
    record(ex, st, ok) {
      if (ok) passed[ex.id] = st;
      else delete passed[ex.id];
    },
    save() {
      try {
        fs.writeFileSync(file, JSON.stringify(passed, null, 2) + '\n');
      } catch {}
    },
  };
}

/** stamp is a cheap change token: mtime and size of every exercise file plus the test. */
export function stamp(ex) {
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
export function hint(ex) {
  const src = fs.readFileSync(ex.test, 'utf8');
  const m = src.match(/\/\*\s*HINT\b([\s\S]*?)\*\//);
  if (!m) return null;
  const lines = m[1].replace(/^\n+|\s+$/g, '').split('\n');
  const pad = Math.min(...lines.filter((l) => l.trim()).map((l) => l.match(/^ */)[0].length));
  return lines.map((l) => l.slice(pad)).join('\n');
}

/** find matches a user-typed name against `name`, `chapter/name` or a path. */
export function find(exs, needle) {
  const n = needle.replace(/\/+$/, '').replace(/\.test\.jsx?$/, '').replace(/\.(js|jsx|sql)$/, '');
  return exs.find(
    (e) => e.name === n || e.id === n || `exercises/${e.id}` === n || e.path === path.resolve(needle),
  );
}

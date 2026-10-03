import fs from 'node:fs';
import path from 'node:path';

export const ROOT = path.resolve(import.meta.dirname, '..');
export const SRC = path.resolve(ROOT, process.env.WEBLINGS_SRC ?? 'exercises');

/** exPath resolves a path inside the exercise tree the tests are pointed at. */
export const exPath = (...parts) => path.join(SRC, ...parts);

export const readEx = (...parts) => fs.readFileSync(exPath(...parts), 'utf8');

export const fixture = (name) => fs.readFileSync(path.join(ROOT, 'tests', 'fixtures', name), 'utf8');

/** freshPg boots an in-memory PGlite and runs the given fixture files in it. */
export async function freshPg(...fixtures) {
  const { PGlite } = await import('@electric-sql/pglite');
  const db = await PGlite.create();
  for (const f of fixtures) await db.exec(fixture(f));
  return db;
}

/** sqlite opens an in-memory node:sqlite database, optionally seeded with fixture files. */
export async function sqlite(...fixtures) {
  const { DatabaseSync } = await import('node:sqlite');
  const db = new DatabaseSync(':memory:');
  for (const f of fixtures) db.exec(fixture(f));
  return db;
}

/** pgError runs `fn` and returns the Postgres error it throws (or null). */
export async function pgError(fn) {
  try {
    await fn();
    return null;
  } catch (e) {
    return e;
  }
}

/** viteBuild builds the vite project in exercises/03_vite/<name> into a temp dir. */
export async function viteBuild(name, inline = {}) {
  const os = await import('node:os');
  const { build } = await import('vite');
  const root = exPath('03_vite', name);
  const outDir = fs.mkdtempSync(path.join(os.tmpdir(), `weblings-${name}-`));
  const config = path.join(root, 'vite.config.js');
  await build({
    ...inline,
    root,
    configFile: fs.existsSync(config) ? config : false,
    logLevel: 'silent',
    build: { ...inline.build, outDir, emptyOutDir: true },
  });
  const files = listTree(outDir);
  return {
    outDir,
    files,
    read: (rel) => fs.readFileSync(path.join(outDir, rel), 'utf8'),
    js: () => files.filter((f) => f.endsWith('.js')).map((f) => fs.readFileSync(path.join(outDir, f), 'utf8')).join('\n'),
    cleanup: () => fs.rmSync(outDir, { recursive: true, force: true }),
  };
}

function listTree(dir, prefix = '') {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((e) =>
    e.isDirectory() ? listTree(path.join(dir, e.name), `${prefix}${e.name}/`) : [`${prefix}${e.name}`],
  );
}

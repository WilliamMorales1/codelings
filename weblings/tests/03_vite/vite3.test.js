import { afterAll, beforeAll, expect, test } from 'vitest';
import { viteBuild } from '../helpers.js';

let out;
beforeAll(async () => {
  out = await viteBuild('vite3');
});
afterAll(() => out?.cleanup());

const jsFiles = () => out.files.filter((f) => f.endsWith('.js'));

test('JS and CSS are emitted into static/', () => {
  expect(jsFiles().length).toBeGreaterThan(0);
  expect(jsFiles().every((f) => f.startsWith('static/'))).toBe(true);
  expect(out.files.some((f) => /^static\/.+\.css$/.test(f))).toBe(true);
});

test('index.html references assets under /app/static/', () => {
  const html = out.read('index.html');
  expect(html).toMatch(/src="\/app\/static\/index-[\w-]+\.js"/);
  expect(html).toMatch(/href="\/app\/static\/index-[\w-]+\.css"/);
});

test('every JS file has a source map', () => {
  for (const f of jsFiles()) expect(out.files).toContain(`${f}.map`);
});

test('a manifest maps index.html to its bundle', () => {
  const manifest = JSON.parse(out.read('.vite/manifest.json'));
  expect(manifest['index.html'].file).toMatch(/^static\/index-[\w-]+\.js$/);
});

/* HINT
`base` is a top-level option, not part of `build`:
    base: '/app/',
    build: { assetsDir: 'static', sourcemap: true, manifest: true },
*/

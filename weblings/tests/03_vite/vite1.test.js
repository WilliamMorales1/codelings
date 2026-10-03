import { afterAll, beforeAll, expect, test } from 'vitest';
import { viteBuild } from '../helpers.js';

let out;
beforeAll(async () => {
  out = await viteBuild('vite1');
});
afterAll(() => out?.cleanup());

test('the build emits a hashed JS bundle', () => {
  expect(out.files.some((f) => /^assets\/index-[\w-]+\.js$/.test(f))).toBe(true);
});

test('dist/index.html loads the bundle as a module', () => {
  const html = out.read('index.html');
  expect(html).toMatch(/<script type="module"[^>]*src="\/assets\/index-[\w-]+\.js"/);
  expect(html).not.toMatch(/<script[^>]*src\/main\.js/);
});

test('the bundle contains the imported code', () => {
  expect(out.js()).toContain('bundled!');
});

/* HINT
Add `type="module"` to the script tag. While you are there, make the path
root-relative: `src="/src/main.js"`.
*/

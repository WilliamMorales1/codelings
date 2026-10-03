import { afterAll, beforeAll, expect, test } from 'vitest';
import { readEx, viteBuild } from '../helpers.js';

let out;
beforeAll(async () => {
  out = await viteBuild('vite2');
});
afterAll(() => out?.cleanup());

test('the API URL and title are baked into the bundle', () => {
  const js = out.js();
  expect(js).toContain('https://api.example.com');
  expect(js).toContain('Weblings Shop');
});

test('the bundle does not use process.env', () => {
  expect(out.js()).not.toMatch(/process\.env/);
});

test('the password stays out of the bundle', () => {
  expect(out.js()).not.toContain('hunter2');
});

test('.env still has the (unexposed) password', () => {
  expect(readEx('03_vite', 'vite2', '.env')).toMatch(/^DB_PASSWORD=hunter2$/m);
});

/* HINT
Rename the two public variables in .env to VITE_API_URL and VITE_APP_TITLE,
and read both through `import.meta.env.VITE_...` in main.js. Leave
DB_PASSWORD alone: without the prefix Vite never exposes it.
*/

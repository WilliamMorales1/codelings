import { afterAll, beforeAll, expect, test } from 'vitest';
import { viteBuild } from '../helpers.js';

let out;
let error;
beforeAll(async () => {
  try {
    out = await viteBuild('vite4');
  } catch (e) {
    error = e;
  }
});
afterAll(() => out?.cleanup());

test('the build resolves every aliased import', () => {
  if (error) throw new Error(`vite build failed:\n${error.message.split('\n').slice(0, 4).join('\n')}`);
});

test('code from both aliased modules is in the bundle', () => {
  const js = out?.js() ?? '';
  expect(js).toContain('btn-aliased');
  expect(js).toContain('EUR ');
});

/* HINT
    import path from 'node:path';
    alias: {
      '@': path.resolve(import.meta.dirname, 'src'),
      '@components': path.resolve(import.meta.dirname, 'src/components'),
    }
*/

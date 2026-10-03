import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('at 1000px wide the wrapper is capped at the md breakpoint (768px)', async () => {
  const page = await load('02_layout/container1');
  expect(page.num('#wrapper', 'max-width', { width: 1000 })).toBe(768);
  expect(page.num('#wrapper', 'max-width', { width: 1400 }), 'and at 1400px, 80rem').toBe(1280);
});

test('the wrapper is centred', async () => {
  const page = await load('02_layout/container1');
  expect(page.get('#wrapper', 'margin-left'), 'margin-left').toBe('auto');
  expect(page.get('#wrapper', 'margin-right'), 'margin-right').toBe('auto');
});

test('the wrapper has 16px side padding', async () => {
  const page = await load('02_layout/container1');
  expect(page.num('#wrapper', 'padding-left'), 'padding-left').toBe(16);
  expect(page.num('#wrapper', 'padding-right'), 'padding-right').toBe(16);
});

/* HINT
Add `mx-auto px-4` next to `container`. In v4 there is no `center` or
`padding` option for it in a config file; you just compose utilities.
*/

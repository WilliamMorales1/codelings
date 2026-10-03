import { expect, test } from 'vitest';
import { load, readEx } from '../helpers.js';

test('a plain .card keeps its padding and colours', async () => {
  const page = await load('07_components/components1');
  expect(page.num('#normal', 'padding-top')).toBe(24);
  expect(page.get('#normal', 'background-color')).toBe(page.theme('--color-white'));
});

test('p-2 overrides the card padding', async () => {
  const page = await load('07_components/components1');
  expect(page.num('#compact', 'padding-top'), '#compact padding').toBe(8);
});

test('shadow-none removes the card shadow', async () => {
  const page = await load('07_components/components1');
  expect(page.get('#flat', 'box-shadow')).not.toContain('#0000001a');
});

test('no !important', async () => {
  expect(readEx('07_components/components1', 'style.css').replace(/\/\*[\s\S]*?\*\//g, '')).not.toContain('!important');
});

/* HINT
Wrap the rule in `@layer components { ... }`. Utilities are in a later
layer, so they win even though `.card` and `.p-2` have equal specificity.
*/

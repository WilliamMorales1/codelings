import { expect, test } from 'vitest';
import { color, load } from '../helpers.js';

test('the three design-system colours work', async () => {
  const page = await load('06_theme/theme3');
  expect(color(page.get('#body', 'background-color'))).toBe('#fafaf9');
  expect(color(page.get('#body', 'color'))).toBe('#111827');
  expect(color(page.get('#cta', 'background-color'))).toBe('#f97316');
});

test('default palette classes generate nothing', async () => {
  const page = await load('06_theme/theme3');
  expect(page.get('#stray', 'background-color'), 'bg-red-500 should not exist').toBeUndefined();
  expect(color(page.get('#stray', 'color')), 'text-blue-600 should not exist (inherits ink)').toBe('#111827');
});

test('no default colour variables are emitted', async () => {
  const page = await load('06_theme/theme3');
  expect(page.css).not.toMatch(/--color-(red|blue)-\d+/);
});

/* HINT
First line inside @theme: `--color-*: initial;`. It clears every default
colour, then your three are added back.
*/

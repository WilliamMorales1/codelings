import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('at rest the button is sky-600', async () => {
  const page = await load('03_states/hover1');
  expect(page.get('#buy', 'background-color')).toBe(page.theme('--color-sky-600'));
});

test('hovered it is sky-700', async () => {
  const page = await load('03_states/hover1');
  expect(page.get('#buy', 'background-color', { hover: '#buy' }), 'background while hovered').toBe(page.theme('--color-sky-700'));
});

test('pressed (hovered + active) it is sky-800', async () => {
  const page = await load('03_states/hover1');
  expect(page.get('#buy', 'background-color', { hover: '#buy', active: '#buy' }), 'background while pressed').toBe(page.theme('--color-sky-800'));
});

test('focused it has a 2px sky-500 outline offset by 2px', async () => {
  const page = await load('03_states/hover1');
  const f = page.style('#buy', { focus: '#buy' });
  expect(f.num('outline-width'), 'outline-width').toBe(2);
  expect(f.get('outline-style'), 'outline-style').toBe('solid');
  expect(f.num('outline-offset'), 'outline-offset').toBe(2);
  expect(f.get('outline-color')).toBe(page.theme('--color-sky-500'));
  expect(page.style('#buy').num('outline-width') || 0, 'no outline when not focused').toBe(0);
});

/* HINT
Variants are prefixes with a colon: `hover:bg-sky-700`, `active:bg-sky-800`.
The outline needs a width and offset as well as a colour:
`focus:outline-2 focus:outline-offset-2 focus:outline-sky-500`.
*/

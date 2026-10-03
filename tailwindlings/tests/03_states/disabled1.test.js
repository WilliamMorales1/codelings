import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the disabled button is faded with a not-allowed cursor', async () => {
  const page = await load('03_states/disabled1');
  expect(Number(page.get('#save', 'opacity')), '#save opacity').toBe(0.5);
  expect(page.get('#save', 'cursor'), '#save cursor').toBe('not-allowed');
});

test('the enabled button is not faded', async () => {
  const page = await load('03_states/disabled1');
  const o = page.get('#cancel', 'opacity');
  expect(o === undefined || Number(o) === 1, `#cancel opacity is ${o}; only disabled buttons fade`).toBe(true);
});

test('the invalid input has a red border', async () => {
  const page = await load('03_states/disabled1');
  expect(page.get('#email', 'border-top-color'), '#email border colour').toBe(page.theme('--color-red-500'));
  page.$('#email').setAttribute('aria-invalid', 'false');
  page.refresh();
  expect(page.get('#email', 'border-top-color'), 'and gray once aria-invalid is false').toBe(page.theme('--color-gray-300'));
  page.$('#email').setAttribute('aria-invalid', 'true');
  page.refresh();
});

test('only the ascending-sorted header is sky-700', async () => {
  const page = await load('03_states/disabled1');
  expect(page.get('#name-col', 'color'), '#name-col (aria-sort=ascending)').toBe(page.theme('--color-sky-700'));
  expect(page.get('#role-col', 'color'), '#role-col (aria-sort=none)').not.toBe(page.theme('--color-sky-700'));
});

test('the pressed toggle is sky-600 with white text', async () => {
  const page = await load('03_states/disabled1');
  expect(page.get('#bold', 'background-color')).toBe(page.theme('--color-sky-600'));
  expect(page.get('#bold', 'color')).toBe(page.theme('--color-white'));
});

/* HINT
`disabled:opacity-50 disabled:cursor-not-allowed` on both buttons (only the
disabled one reacts). `invalid:` tests the :invalid pseudo-class, not the
attribute: use `aria-invalid:border-red-500`. aria-sort has string values,
so it needs brackets: `aria-[sort=ascending]:text-sky-700`. `pressed` is
built in, but as `aria-pressed:`.
*/

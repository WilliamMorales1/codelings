import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the card has a 1px gray-200 border and xl corners', async () => {
  const page = await load('01_utilities/borders1');
  const card = page.style('#card');
  for (const s of ['top', 'right', 'bottom', 'left']) {
    expect(card.num(`border-${s}-width`), `border-${s}-width`).toBe(1);
    expect(card.get(`border-${s}-color`), `border-${s}-color`).toBe(page.theme('--color-gray-200'));
  }
  expect(card.get('border-top-left-radius')).toBe(page.theme('--radius-xl'));
});

test('the active tab only has a bottom border', async () => {
  const page = await load('01_utilities/borders1');
  const tab = page.style('#tab');
  expect(tab.num('border-bottom-width'), 'bottom').toBe(2);
  expect(tab.get('border-bottom-style')).toBe('solid');
  expect(tab.get('border-bottom-color')).toBe(page.theme('--color-sky-500'));
  for (const s of ['top', 'left', 'right']) expect(tab.num(`border-${s}-width`), `border-${s}-width`).toBe(0);
});

test('the badge is a pill', async () => {
  const page = await load('01_utilities/borders1');
  expect(page.num('#badge', 'border-top-left-radius'), 'radius (px)').toBeGreaterThan(1e6);
});

/* HINT
`border` alone is currentColor in v4: add `border-gray-200`. `border-2`
draws all four sides; `border-b-2` only the bottom. `rounded` is a small
radius; `rounded-full` is calc(infinity * 1px), a perfect pill.
*/

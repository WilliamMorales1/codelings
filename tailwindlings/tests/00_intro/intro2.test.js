import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the lede is text-lg', async () => {
  const page = await load('00_intro/intro2');
  expect(page.get('#lede', 'font-size'), 'font-size of #lede').toBe(page.theme('--text-lg'));
});

test('the lede is gray-600', async () => {
  const page = await load('00_intro/intro2');
  expect(page.get('#lede', 'color'), 'color of #lede').toBe(page.theme('--color-gray-600'));
});

/* HINT
Tailwind's font sizes are `text-xs`, `text-sm`, `text-base`, `text-lg`,
`text-xl`, `text-2xl`... and its neutral palettes are `slate`, `gray`, `zinc`,
`neutral` and `stone` (American spelling). Unknown classes are skipped
without any warning, which is why editor autocomplete (the Tailwind CSS
IntelliSense extension) is worth installing.
*/

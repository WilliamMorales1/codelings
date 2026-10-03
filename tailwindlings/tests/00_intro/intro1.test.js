import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the heading is big, bold and sky blue', async () => {
  const page = await load('00_intro/intro1');
  const h1 = page.style('#title');
  expect(h1.get('font-size')).toBe(page.theme('--text-3xl'));
  expect(h1.get('font-weight')).toBe('700');
  expect(h1.get('color')).toBe(page.theme('--color-sky-700'));
});

/* HINT
The heading is not bold yet: add `font-bold` to its class list and save.
*/

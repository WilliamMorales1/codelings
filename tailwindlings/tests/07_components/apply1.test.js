import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('.btn has shape, spacing and weight', async () => {
  const page = await load('07_components/apply1');
  const b = page.style('#cancel');
  expect(b.get('border-top-left-radius'), 'rounded-md').toBe(page.theme('--radius-md'));
  expect(b.num('padding-left'), 'px-4').toBe(16);
  expect(b.num('padding-top'), 'py-2').toBe(8);
  expect(b.get('font-weight'), 'font-semibold').toBe('600');
});

test('.btn-primary is sky with white text, darker on hover', async () => {
  const page = await load('07_components/apply1');
  expect(page.get('#save', 'background-color')).toBe(page.theme('--color-sky-600'));
  expect(page.get('#save', 'color')).toBe(page.theme('--color-white'));
  expect(page.get('#save', 'background-color', { hover: '#save' }), 'hovered').toBe(page.theme('--color-sky-700'));
});

test('utilities still override the component', async () => {
  const page = await load('07_components/apply1');
  expect(page.num('#wide', 'padding-left'), 'px-8 beats .btn').toBe(32);
});

/* HINT
Inside each rule: `@apply rounded-md px-4 py-2 font-semibold;` and
`@apply bg-sky-600 text-white hover:bg-sky-700;`. Keep them inside
`@layer components` so `px-8` (in the utilities layer) still wins.
*/

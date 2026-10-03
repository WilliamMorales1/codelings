import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the popover has the large shadow', async () => {
  const page = await load('01_utilities/shadows1');
  expect(page.get('#popover', 'box-shadow')).toContain(page.theme('--shadow-lg'));
});

test('the popover has a 1px black/5 ring on top of the shadow', async () => {
  const page = await load('01_utilities/shadows1');
  const shadow = page.get('#popover', 'box-shadow');
  expect(shadow, 'a 1px ring').toContain('0 0 0 calc(1px + 0px)');
  expect(shadow, 'ring colour black at 5%').toMatch(/color-mix\(in oklab, #000 5%, transparent\)|#0000000d/);
});

test('the input uses the extra-small shadow', async () => {
  const page = await load('01_utilities/shadows1');
  expect(page.get('#search', 'box-shadow')).toContain(page.theme('--shadow-xs'));
});

/* HINT
Add `ring-1 ring-black/5` next to `shadow-lg`. For the input, use
`shadow-xs`: in v4 a bare `shadow` still works but means `shadow-sm`,
one step bigger than it used to be.
*/

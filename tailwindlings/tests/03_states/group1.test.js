import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('hovering the card (not the title) colours the title', async () => {
  const page = await load('03_states/group1');
  expect(page.get('#title', 'color', { hover: '#card' }), '#title colour with pointer on the card padding').toBe(page.theme('--color-sky-600'));
  expect(page.get('#title', 'color'), '#title colour at rest').not.toBe(page.theme('--color-sky-600'));
});

test('hovering the card nudges the arrow', async () => {
  const page = await load('03_states/group1');
  const t = page.get('#arrow', '--tw-translate-x', { hover: '#card' });
  expect(t, '--tw-translate-x on #arrow').toBeDefined();
  expect(page.num('#arrow', '--tw-translate-x', { hover: '#card' })).toBe(4);
  expect(page.get('#arrow', 'translate', { hover: '#card' })).toBeDefined();
});

/* HINT
Put `group` on the <a>, then change the children's `hover:` to
`group-hover:`. The group-hover selector is
.group-hover\:x:is(:where(.group):hover *), i.e. "inside a hovered .group".
*/

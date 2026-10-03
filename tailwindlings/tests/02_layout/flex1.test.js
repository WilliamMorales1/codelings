import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the bar pushes logo and links to opposite ends, vertically centred', async () => {
  const page = await load('02_layout/flex1');
  const bar = page.style('#bar');
  expect(bar.get('display')).toBe('flex');
  expect(bar.get('justify-content'), 'justify-content').toBe('space-between');
  expect(bar.get('align-items'), 'align-items').toBe('center');
});

test('the links are a flex row with a 24px gap', async () => {
  const page = await load('02_layout/flex1');
  const links = page.style('#links');
  expect(links.get('display'), '#links display (gap does nothing on a block)').toBe('flex');
  expect(links.get('flex-direction') ?? 'row').toBe('row');
  expect(links.num('column-gap'), 'column-gap').toBe(24);
});

/* HINT
`justify-between` puts the free space between the two children, and
`items-center` centres them on the cross axis. `gap-*` only works on flex
and grid containers, so the list needs `flex` too.
*/

import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('stats is a 3-column grid with 16px gaps', async () => {
  const page = await load('02_layout/grid1');
  const s = page.style('#stats');
  expect(s.get('display'), '#stats display').toBe('grid');
  expect(s.get('grid-template-columns')).toBe('repeat(3, minmax(0, 1fr))');
  expect(s.num('row-gap'), 'row-gap').toBe(16);
  expect(s.num('column-gap'), 'column-gap').toBe(16);
});

test('revenue spans two columns', async () => {
  const page = await load('02_layout/grid1');
  expect(page.get('#revenue', 'grid-column'), '#revenue grid-column').toBe('span 2 / span 2');
  expect(page.get('#revenue', 'width'), 'let the grid size it; no width').toBeUndefined();
});

/* HINT
`grid-cols-3` only defines columns; the element also needs `grid`. Use
`gap-4` rather than `space-x-4` (which adds margins and knows nothing about
rows). The wide card is `col-span-2`.
*/

import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the header sticks to the top above the content', async () => {
  const page = await load('02_layout/position1');
  const h = page.style('#header');
  expect(h.get('position'), '#header position').toBe('sticky');
  expect(h.num('top'), '#header top').toBe(0);
  expect(Number(h.get('z-index')), '#header z-index').toBe(10);
});

test('the card is the badge\'s containing block', async () => {
  const page = await load('02_layout/position1');
  expect(page.get('#card', 'position'), '#card position').toBe('relative');
});

test('the badge is 8px from the top-right corner', async () => {
  const page = await load('02_layout/position1');
  const b = page.style('#badge');
  expect(b.get('position')).toBe('absolute');
  expect(b.num('top'), 'top').toBe(8);
  expect(b.num('right'), 'right').toBe(8);
});

/* HINT
`fixed` takes the header out of the flow, so content slides underneath it;
`sticky top-0 z-10` keeps its place in the flow. Give the card `relative`
and the badge `top-2 right-2`.
*/

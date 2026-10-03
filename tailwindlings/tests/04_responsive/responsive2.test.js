import { expect, test } from 'vitest';
import { load } from '../helpers.js';

const cols = (n) => `repeat(${n}, minmax(0, 1fr))`;

test('one column on a 375px phone, 16px gap', async () => {
  const page = await load('04_responsive/responsive2');
  expect(page.get('#products', 'grid-template-columns', { width: 375 })).toBe(cols(1));
  expect(page.num('#products', 'column-gap', { width: 375 })).toBe(16);
});

test('two columns from 640px', async () => {
  const page = await load('04_responsive/responsive2');
  expect(page.get('#products', 'grid-template-columns', { width: 640 }), 'at 640px').toBe(cols(2));
  expect(page.get('#products', 'grid-template-columns', { width: 1000 }), 'at 1000px').toBe(cols(2));
});

test('four columns and a 32px gap from 1024px', async () => {
  const page = await load('04_responsive/responsive2');
  expect(page.get('#products', 'grid-template-columns', { width: 1024 })).toBe(cols(4));
  expect(page.num('#products', 'column-gap', { width: 1024 })).toBe(32);
  expect(page.num('#products', 'row-gap', { width: 1024 })).toBe(32);
});

/* HINT
`grid-cols-1 sm:grid-cols-2 lg:grid-cols-4` and `gap-4 lg:gap-8`.
*/

import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('md:scrollbar-hidden hides the scrollbar from 768px', async () => {
  const page = await load('07_components/utility1');
  expect(page.get('#chips', 'scrollbar-width', { width: 1024 }), 'scrollbar-width at 1024px').toBe('none');
});

test('below md the scrollbar stays', async () => {
  const page = await load('07_components/utility1');
  expect(page.get('#chips', 'scrollbar-width', { width: 375 }), 'scrollbar-width at 375px').toBeUndefined();
});

test('the webkit scrollbar is hidden too', async () => {
  const page = await load('07_components/utility1');
  expect(page.css, 'a md:scrollbar-hidden rule for ::-webkit-scrollbar').toMatch(/\.md\\:scrollbar-hidden::-webkit-scrollbar\s*\{\s*display:\s*none/);
});

/* HINT
Change `.scrollbar-hidden {` to `@utility scrollbar-hidden {`. The body
stays the same; Tailwind now generates it on demand, with every variant.
*/

import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the file name truncates on one line', async () => {
  const page = await load('08_polish/typography2');
  const f = page.style('#file');
  expect(f.get('text-overflow')).toBe('ellipsis');
  expect(f.get('white-space'), 'white-space').toBe('nowrap');
  expect(f.get('overflow-x'), 'overflow').toBe('hidden');
});

test('the summary is clamped to 3 lines', async () => {
  const page = await load('08_polish/typography2');
  expect(page.get('#summary', '-webkit-line-clamp'), '-webkit-line-clamp').toBe('3');
  expect(page.get('#summary', 'display')).toBe('-webkit-box');
});

test('the headline is balanced', async () => {
  const page = await load('08_polish/typography2');
  expect(page.get('#headline', 'text-wrap')).toBe('balance');
});

test('the price uses tabular numbers', async () => {
  const page = await load('08_polish/typography2');
  expect(page.get('#price', 'font-variant-numeric')).toContain('tabular-nums');
});

test('the link underline is 2px, sky-500, offset 4px', async () => {
  const page = await load('08_polish/typography2');
  const l = page.style('#more');
  expect(l.get('text-decoration-line')).toBe('underline');
  expect(l.get('text-decoration-color'), 'decoration colour').toBe(page.theme('--color-sky-500'));
  expect(l.num('text-decoration-thickness'), 'thickness').toBe(2);
  expect(l.num('text-underline-offset'), 'offset').toBe(4);
});

/* HINT
`truncate`, `line-clamp-3`, `text-balance`, `tabular-nums`, and
`decoration-sky-500 decoration-2 underline-offset-4` next to `underline`.
*/

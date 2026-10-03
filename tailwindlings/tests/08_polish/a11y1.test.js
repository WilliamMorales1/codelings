import { expect, test } from 'vitest';
import { load } from '../helpers.js';

function expectSrOnly(page, sel, env) {
  const s = page.style(sel, env);
  expect(s.get('display'), `${sel} must not be display: none`).not.toBe('none');
  expect(s.get('position'), `${sel} position`).toBe('absolute');
  expect(s.num('width'), `${sel} width`).toBe(1);
  expect(s.get('clip-path'), `${sel} clip-path`).toBe('inset(50%)');
}

test('the close label is visually hidden but readable', async () => {
  const page = await load('08_polish/a11y1');
  expectSrOnly(page, '#close-label');
});

test('keyboard focus on the close button shows an outline', async () => {
  const page = await load('08_polish/a11y1');
  const f = page.style('#close', { focusVisible: '#close' });
  expect(f.num('outline-width'), 'outline-width').toBe(2);
  expect(f.get('outline-style'), 'outline-style').toBe('solid');
  expect(f.num('outline-offset'), 'outline-offset').toBe(2);
  expect(f.get('outline-color')).toBe(page.theme('--color-sky-600'));
});

test('the skip link is sr-only at rest', async () => {
  const page = await load('08_polish/a11y1');
  expectSrOnly(page, '#skip');
});

test('the skip link appears when focused', async () => {
  const page = await load('08_polish/a11y1');
  const f = page.style('#skip', { focusVisible: '#skip' });
  expect(f.get('display'), 'display').not.toBe('none');
  expect(f.get('position'), 'position').toBe('static');
  expect(f.get('width'), 'width').toBe('auto');
});

/* HINT
Label: `sr-only` instead of `hidden`. Button: replace `focus:outline-none`
with `focus-visible:outline-2 focus-visible:outline-offset-2
focus-visible:outline-sky-600`. Skip link: `sr-only focus:not-sr-only`.
*/

import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the email placeholder is gray-400', async () => {
  const page = await load('07_components/forms1');
  expect(page.$('#email').classList.contains('placeholder:text-gray-400'), '#email has placeholder:text-gray-400').toBe(true);
  expect(page.css).toMatch(/\.placeholder\\:text-gray-400::placeholder\s*\{\s*color: var\(--color-gray-400\)/);
});

test('focusing the email shows a sky border and ring', async () => {
  const page = await load('07_components/forms1');
  const f = page.style('#email', { focus: '#email' });
  expect(f.get('border-top-color'), 'focused border').toBe(page.theme('--color-sky-500'));
  const shadow = f.get('box-shadow') ?? '';
  expect(shadow, 'a 2px ring in the box-shadow').toContain('0 0 0 calc(2px + 0px)');
  expect(shadow, 'ring colour sky-500 at 30%').toMatch(/color-mix\(in oklab, oklch\(68\.5% \.169 237\.323\) 30%, transparent\)/);
});

test('the unfocused email has no ring', async () => {
  const page = await load('07_components/forms1');
  expect(page.get('#email', 'box-shadow') ?? '').not.toContain('calc(2px');
});

test('the checkbox accent is sky-600', async () => {
  const page = await load('07_components/forms1');
  expect(page.get('#terms', 'accent-color')).toBe(page.theme('--color-sky-600'));
});

test('the disabled field is gray-100', async () => {
  const page = await load('07_components/forms1');
  expect(page.get('#company', 'background-color')).toBe(page.theme('--color-gray-100'));
});

/* HINT
#email: add `placeholder:text-gray-400 focus:border-sky-500 focus:ring-2
focus:ring-sky-500/30`. #terms: `accent-sky-600` (text colour does not
reach native checkboxes). #company: variants go first,
`disabled:bg-gray-100`.
*/

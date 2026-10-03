import { expect, test } from 'vitest';
import { load } from '../helpers.js';

const setDark = (page, on) => {
  page.document.documentElement.classList.toggle('dark', on);
  page.refresh();
};

test('the OS preference alone no longer switches the theme', async () => {
  const page = await load('05_dark_mode/dark2');
  setDark(page, false);
  expect(page.get('#body', 'background-color', { scheme: 'dark' }), 'OS dark, no .dark class').toBe(page.theme('--color-white'));
});

test('html.dark switches the theme, even with a light OS', async () => {
  const page = await load('05_dark_mode/dark2');
  setDark(page, true);
  expect(page.get('#body', 'background-color', { scheme: 'light' }), 'OS light, .dark on <html>').toBe(page.theme('--color-gray-950'));
  expect(page.get('#body', 'color', { scheme: 'light' })).toBe(page.theme('--color-gray-100'));
  setDark(page, false);
});

/* HINT
Below the import, add:
  @custom-variant dark (&:where(.dark, .dark *));
`&` is the element being styled; :where() keeps specificity at zero, so
dark: utilities win over the light ones only by coming later.
*/

import { expect, test } from 'vitest';
import { load } from '../helpers.js';

const dark = { scheme: 'dark' };

test('light mode is unchanged', async () => {
  const page = await load('05_dark_mode/dark1');
  expect(page.get('#body', 'background-color')).toBe(page.theme('--color-white'));
  expect(page.get('#body', 'color')).toBe(page.theme('--color-gray-900'));
  expect(page.get('#card', 'border-top-color')).toBe(page.theme('--color-gray-200'));
  expect(page.get('#muted', 'color')).toBe(page.theme('--color-gray-500'));
});

test('dark mode: page and text', async () => {
  const page = await load('05_dark_mode/dark1');
  expect(page.get('#body', 'background-color', dark), 'body background').toBe(page.theme('--color-gray-950'));
  expect(page.get('#body', 'color', dark), 'body text').toBe(page.theme('--color-gray-100'));
});

test('dark mode: card and muted text', async () => {
  const page = await load('05_dark_mode/dark1');
  expect(page.get('#card', 'background-color', dark), 'card background').toBe(page.theme('--color-gray-900'));
  expect(page.get('#card', 'border-top-color', dark), 'card border').toBe(page.theme('--color-gray-700'));
  expect(page.get('#muted', 'color', dark), 'muted text').toBe(page.theme('--color-gray-400'));
});

/* HINT
Every colour that should change needs its own dark: twin:
`dark:text-gray-100` on body, `dark:border-gray-700` on the card,
`dark:text-gray-400` on the muted paragraph.
*/

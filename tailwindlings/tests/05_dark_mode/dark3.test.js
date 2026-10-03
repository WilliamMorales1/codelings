import { expect, test } from 'vitest';
import { load } from '../helpers.js';

const theme = (page, t) => {
  page.document.documentElement.dataset.theme = t;
  page.refresh();
};

test('data-theme="dark" turns dark mode on', async () => {
  const page = await load('05_dark_mode/dark3');
  theme(page, 'dark');
  expect(page.get('#link', 'color'), 'link colour with data-theme=dark').toBe(page.theme('--color-sky-400'));
});

test('dark + hover is sky-300', async () => {
  const page = await load('05_dark_mode/dark3');
  theme(page, 'dark');
  expect(page.get('#link', 'color', { hover: '#link' })).toBe(page.theme('--color-sky-300'));
});

test('light mode keeps sky-700 / sky-900 on hover', async () => {
  const page = await load('05_dark_mode/dark3');
  theme(page, 'light');
  expect(page.get('#link', 'color', { scheme: 'dark' }), 'light theme even when the OS is dark').toBe(page.theme('--color-sky-700'));
  expect(page.get('#link', 'color', { hover: '#link' }), 'light + hover').toBe(page.theme('--color-sky-900'));
  theme(page, 'dark');
});

/* HINT
style.css: @custom-variant dark (&:where([data-theme=dark], [data-theme=dark] *));
index.html: the second hover class needs the dark prefix too:
`dark:hover:text-sky-300`. A plain `hover:text-sky-300` also fires in
light mode (and wins over hover:text-sky-900 because it comes later).
*/

import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('font-display is Lexend with a sans-serif fallback', async () => {
  const page = await load('06_theme/theme2');
  expect(page.get('#title', 'font-family'), '#title font-family').toMatch(/^["']?Lexend["']?,\s*sans-serif$/);
});

test('the 3xl breakpoint switches to 6 columns at 1920px', async () => {
  const page = await load('06_theme/theme2');
  const cols = (w) => page.get('#gallery', 'grid-template-columns', { width: w });
  expect(cols(1919), 'at 1919px').toBe('repeat(4, minmax(0, 1fr))');
  expect(cols(1920), 'at 1920px').toBe('repeat(6, minmax(0, 1fr))');
});

test('existing breakpoints still work', async () => {
  const page = await load('06_theme/theme2');
  expect(page.get('#gallery', 'grid-template-columns', { width: 375 })).toBe('repeat(2, minmax(0, 1fr))');
});

/* HINT
Inside @theme:
  --font-display: "Lexend", sans-serif;
  --breakpoint-3xl: 120rem;
Adding a variable extends the default theme; nothing else is lost.
*/

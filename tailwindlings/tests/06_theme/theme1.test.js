import { expect, test } from 'vitest';
import { color, load } from '../helpers.js';

test('brand colours exist as theme variables', async () => {
  const page = await load('06_theme/theme1');
  expect(color(page.get('html', '--color-brand-600')), '--color-brand-600 on :root').toBe('#7c3aed');
});

test('the button is brand-600, brand-700 on hover', async () => {
  const page = await load('06_theme/theme1');
  expect(color(page.get('#cta', 'background-color')), '#cta background').toBe('#7c3aed');
  expect(color(page.get('#cta', 'background-color', { hover: '#cta' })), '#cta hovered').toBe('#6d28d9');
});

test('the title text is brand-600', async () => {
  const page = await load('06_theme/theme1');
  expect(color(page.get('#title', 'color'))).toBe('#7c3aed');
});

/* HINT
Replace the :root block with
  @theme {
    --color-brand-600: #7c3aed;
    --color-brand-700: #6d28d9;
  }
The `--color-` prefix is what makes them colour utilities.
*/

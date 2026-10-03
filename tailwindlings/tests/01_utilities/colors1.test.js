import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the warning is amber-50 on amber-900', async () => {
  const page = await load('01_utilities/colors1');
  expect(page.get('#warning', 'background-color'), '#warning background').toBe(page.theme('--color-amber-50'));
  expect(page.get('#warning', 'color'), '#warning text colour').toBe(page.theme('--color-amber-900'));
});

test('the backdrop is 50% black', async () => {
  const page = await load('01_utilities/colors1');
  const bg = page.get('#backdrop', 'background-color');
  expect(bg, '#backdrop background').toMatch(/^color-mix\(in oklab, #000 50%, transparent\)$|^#00000080$/);
});

test('the dialog is not faded', async () => {
  const page = await load('01_utilities/colors1');
  for (const sel of ['#backdrop', '#dialog']) {
    const o = page.get(sel, 'opacity');
    expect(o === undefined || Number(o) === 1, `${sel} opacity is ${o}; opacity fades children too`).toBe(true);
  }
});

/* HINT
Shades are required: `bg-amber-50`, `text-amber-900`. For the backdrop,
drop `opacity-50` and put the alpha on the colour instead: `bg-black/50`.
Tailwind turns that into color-mix(in oklab, var(--color-black) 50%, transparent),
which only affects the background.
*/

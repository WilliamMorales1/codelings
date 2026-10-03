import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the header centres everything inside it', async () => {
  const page = await load('01_utilities/typography1');
  expect(page.get('#header', 'text-align'), '#header text-align').toBe('center');
  expect(page.get('#headline', 'text-align'), '#headline inherits text-align').toBe('center');
  expect(page.get('#kicker', 'text-align'), '#kicker inherits text-align').toBe('center');
  expect(page.$('#headline').classList.contains('text-center'), 'put text-center on the header only').toBe(false);
});

test('the kicker is uppercase', async () => {
  const page = await load('01_utilities/typography1');
  expect(page.get('#kicker', 'text-transform')).toBe('uppercase');
});

test('the headline is 4xl, weight 800, tight', async () => {
  const page = await load('01_utilities/typography1');
  const h = page.style('#headline');
  expect(h.get('font-size')).toBe(page.theme('--text-4xl'));
  expect(h.get('font-weight'), 'font-weight').toBe('800');
  expect(h.get('letter-spacing'), 'letter-spacing').toBe(page.theme('--tracking-tight'));
});

test('the body copy is text-base with a 28px line-height', async () => {
  const page = await load('01_utilities/typography1');
  expect(page.get('#body', 'font-size')).toBe(page.theme('--text-base'));
  expect(page.num('#body', 'line-height'), 'line-height in px').toBe(28);
});

/* HINT
`text-center` on the header, `uppercase` on the kicker,
`font-extrabold tracking-tight` on the h1 (no dash inside "extrabold"),
and `text-base/7` (or `text-base leading-7`) on the paragraph.
*/

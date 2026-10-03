import { expect, test } from 'vitest';
import { load } from '../helpers.js';

const sides = ['top', 'right', 'bottom', 'left'];

test('the card has 1.5rem (24px) padding on every side', async () => {
  const page = await load('01_utilities/spacing1');
  for (const s of sides) expect(page.num('#card', `padding-${s}`), `#card padding-${s}`).toBe(24);
});

test('the title is separated by margin, not padding', async () => {
  const page = await load('01_utilities/spacing1');
  expect(page.num('#title', 'margin-bottom'), '#title margin-bottom').toBe(8);
  expect(page.num('#title', 'padding-bottom'), '#title padding-bottom').toBe(0);
});

test('the button has 16px x 8px padding and 16px above it', async () => {
  const page = await load('01_utilities/spacing1');
  expect(page.num('#cta', 'padding-left')).toBe(16);
  expect(page.num('#cta', 'padding-right')).toBe(16);
  expect(page.num('#cta', 'padding-top'), '#cta padding-top').toBe(8);
  expect(page.num('#cta', 'padding-bottom'), '#cta padding-bottom').toBe(8);
  expect(page.num('#cta', 'margin-top'), '#cta margin-top').toBe(16);
});

/* HINT
One step of the scale is 0.25rem = 4px, so 24px is `p-6`, 8px is `mb-2`,
16px is `px-4` / `mt-4` and 8px vertically is `py-2`. There is no
`padding-6` class, and `pb-2` pads inside the title instead of pushing the
paragraph away.
*/

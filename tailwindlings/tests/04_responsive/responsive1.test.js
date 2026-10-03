import { expect, test } from 'vitest';
import { load } from '../helpers.js';

const phone = { width: 375 };
const tablet = { width: 800 };
const desktop = { width: 1280 };
const shown = (d) => d !== 'none';

test('phone: hamburger visible, links hidden', async () => {
  const page = await load('04_responsive/responsive1');
  expect(shown(page.get('#burger', 'display', phone)), '#burger at 375px').toBe(true);
  expect(page.get('#links', 'display', phone), '#links at 375px').toBe('none');
});

test('md and up: hamburger hidden, links in a flex row', async () => {
  const page = await load('04_responsive/responsive1');
  for (const env of [tablet, desktop]) {
    expect(page.get('#burger', 'display', env), `#burger at ${env.width}px`).toBe('none');
    expect(page.get('#links', 'display', env), `#links at ${env.width}px`).toBe('flex');
  }
});

test('the headline is centred on phones and left-aligned from md', async () => {
  const page = await load('04_responsive/responsive1');
  expect(page.get('#headline', 'text-align', phone), 'at 375px').toBe('center');
  expect(page.get('#headline', 'text-align', { width: 700 }), 'at 700px').toBe('center');
  expect(page.get('#headline', 'text-align', desktop), 'at 1280px').toBe('left');
});

/* HINT
Write the phone version without prefixes, then override upward:
burger `md:hidden`; links `hidden md:flex`; headline
`text-center md:text-left`. `sm:text-center` only kicks in at 640px and
above, which is the opposite of what was meant.
*/

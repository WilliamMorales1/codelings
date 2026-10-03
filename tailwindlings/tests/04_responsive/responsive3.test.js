import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the banner only shows from 768px to 1023px', async () => {
  const page = await load('04_responsive/responsive3');
  const at = (w) => page.get('#banner', 'display', { width: w });
  expect(at(375), 'at 375px').toBe('none');
  expect(at(767), 'at 767px').toBe('none');
  expect(at(768), 'at 768px').toBe('block');
  expect(at(1023), 'at 1023px').toBe('block');
  expect(at(1024), 'at 1024px').toBe('none');
  expect(at(1600), 'at 1600px').toBe('none');
});

test('the button is full width only below 640px', async () => {
  const page = await load('04_responsive/responsive3');
  expect(page.get('#subscribe', 'width', { width: 375 }), 'at 375px').toBe('100%');
  expect(page.get('#subscribe', 'width', { width: 639 }), 'at 639px').toBe('100%');
  expect(page.get('#subscribe', 'width', { width: 640 }), 'at 640px').toBeUndefined();
  expect(page.get('#subscribe', 'width', { width: 1280 }), 'at 1280px').toBeUndefined();
});

/* HINT
Banner: `hidden md:max-lg:block`. Button: `max-sm:w-full` (instead of a
`w-full` that applies everywhere).
*/

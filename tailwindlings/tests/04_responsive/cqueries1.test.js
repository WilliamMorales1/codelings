import { expect, test } from 'vitest';
import { load } from '../helpers.js';

// data-width on each slot tells the test harness how wide that container renders.

test('both slots are size containers', async () => {
  const page = await load('04_responsive/cqueries1');
  for (const slot of page.$$('.card-slot')) expect(page.get(slot, 'container-type'), `${slot.tagName.toLowerCase()} container-type`).toBe('inline-size');
});

test('on a wide screen the sidebar card (288px container) stays a column', async () => {
  const page = await load('04_responsive/cqueries1');
  expect(page.get('#small', 'flex-direction', { width: 1440 })).toBe('column');
});

test('the main card (900px container) is a row', async () => {
  const page = await load('04_responsive/cqueries1');
  expect(page.get('#large', 'flex-direction', { width: 1440 })).toBe('row');
});

test('the main card follows its container, not the viewport', async () => {
  const page = await load('04_responsive/cqueries1');
  // A wide phone in landscape: viewport 800px, but the main slot only 400px.
  expect(page.get('#large', 'flex-direction', { width: 800, container: 400 })).toBe('column');
  expect(page.get('#large', 'flex-direction', { width: 600, container: 448 })).toBe('row');
});

/* HINT
Add `@container` to both `.card-slot` elements and change `md:flex-row`
(viewport) to `@md:flex-row` (nearest container >= 28rem).
*/

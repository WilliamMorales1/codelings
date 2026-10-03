import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the active tab is white with sky-700 text', async () => {
  const page = await load('03_states/data1');
  expect(page.get('#tab-a', 'background-color'), '#tab-a background').toBe(page.theme('--color-white'));
  expect(page.get('#tab-a', 'color'), '#tab-a text').toBe(page.theme('--color-sky-700'));
});

test('the inactive tab keeps the defaults', async () => {
  const page = await load('03_states/data1');
  expect(page.get('#tab-b', 'background-color')).not.toBe(page.theme('--color-white'));
  expect(page.get('#tab-b', 'color')).toBe(page.theme('--color-gray-600'));
});

test('the menu shows only while data-open is present', async () => {
  const page = await load('03_states/data1');
  expect(page.get('#menu', 'display'), 'with data-open').toBe('block');
  page.$('#menu').removeAttribute('data-open');
  page.refresh();
  expect(page.get('#menu', 'display'), 'without data-open').toBe('none');
  page.$('#menu').setAttribute('data-open', '');
  page.refresh();
});

/* HINT
Arbitrary attribute values go in brackets: `data-[state=active]:bg-white`.
For a present/absent attribute, `data-open:` matches [data-open]. The
`open:` variant is something else: it matches the :open / [open] state of
<details> and <dialog>.
*/

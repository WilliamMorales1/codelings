import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

const items = (page) => page.$$('#log > li').map((li) => li.textContent);

test('events are appended in order', async () => {
  const page = await openPage('01_basics', 'swap1');
  for (const n of [1, 2, 3]) {
    page.click('#event');
    await page.until(() => items(page).length === n, `${n} items in #log`);
  }
  expect(items(page)).toEqual(['event 1', 'event 2', 'event 3']);
});

test('pinned notes go to the top', async () => {
  const page = await openPage('01_basics', 'swap1');
  page.click('#event');
  await page.until(() => items(page).length === 1, 'one item in #log');
  page.click('#event');
  await page.until(() => items(page).length === 2, 'two items in #log');
  page.click('#pin');
  await page.until(() => items(page).length === 3, 'three items in #log');
  expect(items(page)).toEqual(['pinned note', 'event 1', 'event 2']);
});

/* HINT
Add hx-swap="beforeend" to the event button and hx-swap="afterbegin" to
the pin button.
*/

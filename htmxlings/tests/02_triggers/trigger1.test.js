import { expect, test } from 'vitest';
import { openPage, sleep } from '../helpers.js';

const searches = (page) => page.htmxRequests().filter((r) => r.path === '/search');

test('fast typing sends a single request with the whole word', async () => {
  const page = await openPage('02_triggers', 'trigger1');
  page.type('#q', 'htm');
  await page.until(() => searches(page).length > 0, 'a GET /search', 3000);
  await sleep(700);
  expect(searches(page).map((r) => r.query.q)).toEqual(['htm']);
  await page.until(() => page.$$('#results li').length === 2, 'two results');
});

test('keys that do not change the value send nothing', async () => {
  const page = await openPage('02_triggers', 'trigger1');
  page.type('#q', 'ht');
  await page.until(() => searches(page).length === 1, 'the first search', 3000);
  page.fire('#q', 'keyup');
  page.fire('#q', 'keyup');
  await sleep(700);
  expect(searches(page)).toHaveLength(1);
});

test('the request waits for a pause in typing', async () => {
  const page = await openPage('02_triggers', 'trigger1');
  page.type('#q', 'h');
  await sleep(100);
  expect(searches(page), 'no request should go out within 100ms of a keystroke').toHaveLength(0);
});

/* HINT
Modifiers go after the event name, separated by spaces:
hx-trigger="keyup changed delay:300ms"
*/

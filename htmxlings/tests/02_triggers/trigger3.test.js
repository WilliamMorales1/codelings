import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('the status keeps refreshing', async () => {
  const page = await openPage('02_triggers', 'trigger3');
  await page.until(() => page.$('#n')?.textContent === '3', 'the third status check', 2000);
  const polls = page.htmxRequests().filter((r) => r.path === '/status');
  expect(polls.length).toBeGreaterThanOrEqual(3);
});

/* HINT
hx-trigger="every 300ms". "load" fires once; "every" keeps going.
*/

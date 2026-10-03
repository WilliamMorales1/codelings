import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('the token rides along on every request', async () => {
  const page = await openPage('08_events_extensions', 'events1', {
    beforeLoad: (w) => w.localStorage.setItem('token', 'abc123'),
  });
  page.click('button');
  await page.until(() => page.text('#out'), 'an answer in #out');
  expect(page.text('#out')).toBe('Balance: 42 EUR');
  expect(page.htmxRequests()[0].query.token).toBe('abc123');
});

/* HINT
Listen for htmx:configRequest instead, and add to the existing object:
  event.detail.parameters.token = localStorage.getItem('token');
*/

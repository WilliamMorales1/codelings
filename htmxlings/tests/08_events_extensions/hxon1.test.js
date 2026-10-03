import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('a saved note clears the input', async () => {
  const page = await openPage('08_events_extensions', 'hxon1');
  page.$('input').value = 'buy milk';
  page.submit('form');
  await page.until(() => page.$$('#notes li').length === 1, 'the note in the list');
  await page.until(() => page.$('input').value === '', 'the input to be cleared', 1000);
});

test('a rejected note stays in the input', async () => {
  const page = await openPage('08_events_extensions', 'hxon1');
  const long = 'this note is far too long to keep';
  page.$('input').value = long;
  page.submit('form');
  await page.until(() => page.htmxRequests().length === 1, 'the request');
  await page.idle(150);
  expect(page.$('input').value).toBe(long);
  expect(page.$$('#notes li')).toHaveLength(0);
});

/* HINT
hx-on::after-request="if (event.detail.successful) this.reset()"
*/

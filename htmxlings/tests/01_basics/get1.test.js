import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('clicking the button issues an htmx GET /quote', async () => {
  const page = await openPage('01_basics', 'get1');
  page.click('#load');
  const req = await page.until(() => page.htmxRequests().find((r) => r.path === '/quote'), 'a GET /quote from htmx');
  expect(req.method).toBe('GET');
});

test('the quote lands in #quote and the button survives', async () => {
  const page = await openPage('01_basics', 'get1');
  page.click('#load');
  await page.until(() => page.$('#quote blockquote'), 'a <blockquote> inside #quote');
  expect(page.text('#load')).toBe('Load a quote');
  expect(page.$('#load blockquote')).toBeNull();
});

/* HINT
Replace `href` with `hx-get="/quote"` and add `hx-target="#quote"`.
Without hx-target the quote would be swapped into the button itself.
*/

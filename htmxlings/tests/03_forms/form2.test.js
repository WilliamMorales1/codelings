import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('sorting keeps the filter', async () => {
  const page = await openPage('03_forms', 'form2');
  page.$('#q').value = 'web';
  page.$('select').value = 'year';
  page.fire('select', 'change');
  const req = await page.until(() => page.htmxRequests().find((r) => r.path === '/books'), 'a GET /books');
  expect(req.query).toEqual({ q: 'web', sort: 'year' });
  await page.until(() => page.$$('#books li').length === 1, 'exactly one filtered book');
  expect(page.text('#books')).toContain('RESTful Web APIs');
});

/* HINT
Add hx-include="#q" to the <select>.
*/

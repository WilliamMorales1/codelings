import { expect, test } from 'vitest';
import { openPage, serve } from '../helpers.js';

test('the last row of a page asks for the next one and swaps after itself', async () => {
  const srv = await serve('06_patterns', 'infinite');
  const body = await (await srv.fetch('/agents?page=2')).text();
  const tr = body.match(/<tr [^>]*>/g);
  expect(tr).toHaveLength(1);
  expect(tr[0]).toContain('hx-get="/agents?page=3"');
  expect(tr[0]).toContain('hx-trigger="revealed"');
  expect(tr[0]).toContain('hx-swap="afterend"');
  const lastPage = await (await srv.fetch('/agents?page=5')).text();
  expect(lastPage).not.toContain('hx-get');
});

test('scrolling loads every agent as flat rows', async () => {
  // jsdom has no layout, so every "revealed" row counts as visible at once.
  const page = await openPage('06_patterns', 'infinite');
  await page.until(() => page.$$('tbody > tr').length === 50, '50 rows directly inside <tbody>', 4000);
  await page.idle();
  expect(page.$('tbody tr tr')).toBeNull();
  const pages = page.htmxRequests().map((r) => r.query.page);
  expect(pages).toEqual(['1', '2', '3', '4', '5']);
});

/* HINT
Add hx-swap="afterend" to the last row. Without it the response replaces
the row's own contents (innerHTML), nesting rows inside a row.
*/

import { expect, test } from 'vitest';
import { openPage, serve } from '../helpers.js';

test('a plain browser visit gets the whole page', async () => {
  const srv = await serve('05_headers', 'hxrequest1');
  const body = await (await srv.fetch('/inbox')).text();
  expect(body).toMatch(/<html/);
  expect(body).toContain('src="/htmx.js"');
  expect(body).toContain('class="inbox"');
});

test('htmx gets only the fragment', async () => {
  const srv = await serve('05_headers', 'hxrequest1');
  const body = await (await srv.fetch('/inbox', { headers: { 'HX-Request': 'true' } })).text();
  expect(body).not.toMatch(/<html|<h1|<nav/);
  expect(body).toContain('class="inbox"');
});

test('clicking Inbox fills #main without nesting a page', async () => {
  const page = await openPage('05_headers', 'hxrequest1');
  page.click('nav button');
  await page.until(() => page.$('#main .inbox'), 'the inbox list in #main');
  expect(page.$$('h1')).toHaveLength(1);
  expect(page.$$('#main li')).toHaveLength(3);
});

/* HINT
headers['hx-request'] === 'true' ? inbox() : layout(inbox())
*/

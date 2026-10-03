import { expect, test } from 'vitest';
import { openPage, serve } from '../helpers.js';

test('POST /like answers with an HTML fragment', async () => {
  const srv = await serve('01_basics', 'post1');
  const res = await srv.fetch('/like', { method: 'POST' });
  expect(res.headers.get('content-type')).toContain('text/html');
  const body = await res.text();
  expect(body).toMatch(/^\s*<span id="likes">1 likes?<\/span>\s*$/);
});

test('each click updates the counter in place', async () => {
  const page = await openPage('01_basics', 'post1');
  page.click('button');
  await page.until(() => page.text('#likes') === '1 likes', '#likes to read "1 likes"');
  page.click('button');
  await page.until(() => page.text('#likes') === '2 likes', '#likes to read "2 likes"');
  expect(page.$$('#likes')).toHaveLength(1);
});

/* HINT
Return html`<span id="likes">${likes} likes</span>` from the handler.
A plain string return is sent as text/html with status 200.
*/

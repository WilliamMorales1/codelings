import { expect, test } from 'vitest';
import { openPage, serve } from '../helpers.js';

test('the page itself answers fast, without the report', async () => {
  const srv = await serve('06_patterns', 'lazyload');
  const t0 = Date.now();
  const body = await (await srv.fetch('/')).text();
  expect(Date.now() - t0, 'GET / should not wait for the report').toBeLessThan(300);
  expect(body).toContain('id="intro"');
  expect(body).not.toContain('id="report"');
  expect(body).toMatch(/hx-get="\/report"/);
});

test('the report arrives and replaces the placeholder', async () => {
  const page = await openPage('06_patterns', 'lazyload');
  expect(page.$('#report')).toBeNull();
  await page.until(() => page.$('#report'), '#report to load', 3000);
  await page.idle();
  expect(page.document.body.textContent).not.toMatch(/Loading/);
  expect(page.$('#report').parentElement).toBe(page.document.body);
});

/* HINT
'GET /': () => layout(html`<div hx-get="/report" hx-trigger="load" hx-swap="outerHTML">Loading report...</div>`),
'GET /report': () => slowReport(),
*/

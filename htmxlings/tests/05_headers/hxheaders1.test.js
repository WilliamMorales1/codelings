import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('both buttons send the CSRF header', async () => {
  const page = await openPage('05_headers', 'hxheaders1');
  page.click('#save');
  await page.until(() => page.text('#out') === 'saved', '"saved" in #out');
  page.click('#reset');
  await page.until(() => page.text('#out') === 'reset', '"reset" in #out');
  for (const r of page.htmxRequests()) {
    expect(r.headers['x-csrf-token']).toBe('s3cr3t');
    expect(r.form).not.toHaveProperty('X-CSRF-Token');
  }
});

test('the header is set once, on <body>', async () => {
  const page = await openPage('05_headers', 'hxheaders1');
  expect(page.document.body.getAttribute('hx-headers')).toMatch(/X-CSRF-Token/);
  expect(page.$$('[hx-headers]')).toHaveLength(1);
});

/* HINT
Remove the hx-vals and write <body hx-headers='{"X-CSRF-Token": "s3cr3t"}'>.
Both buttons inherit it.
*/

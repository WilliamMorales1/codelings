import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('submitting posts the email over htmx and shows the thanks', async () => {
  const page = await openPage('03_forms', 'form1');
  page.$('input[name=email]').value = 'ada@example.com';
  page.submit('form');
  await page.until(() => page.$('#result .thanks'), 'the thanks message in #result');
  expect(page.text('#result')).toBe('Thanks, ada@example.com!');
  const req = page.htmxRequests().find((r) => r.path === '/subscribe');
  expect(req.form).toEqual({ email: 'ada@example.com' });
  expect(page.$('form'), 'the form should still be there').not.toBeNull();
});

/* HINT
<form hx-post="/subscribe" hx-target="#result">. You can drop action and
method, or keep them as a no-JavaScript fallback.
*/

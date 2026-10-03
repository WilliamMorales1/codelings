import { expect, test } from 'vitest';
import { openPage, sleep } from '../helpers.js';

test('confirming sends DELETE /account', async () => {
  const asked = [];
  const page = await openPage('03_forms', 'form6', { beforeLoad: (w) => (w.confirm = (m) => (asked.push(m), true)) });
  page.click('button');
  await page.until(() => page.$('#gone'), 'the goodbye message');
  expect(asked).toEqual(['Really delete your account?']);
  expect(page.htmxRequests().map((r) => r.method)).toEqual(['DELETE']);
});

test('cancelling sends nothing', async () => {
  const page = await openPage('03_forms', 'form6', { confirm: false });
  page.click('button');
  await sleep(200);
  expect(page.htmxRequests()).toHaveLength(0);
  expect(page.$('button')).not.toBeNull();
});

/* HINT
Swap hx-post for hx-delete and add hx-confirm="Really delete your account?".
*/

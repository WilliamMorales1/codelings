import { expect, test } from 'vitest';
import { openPage, sleep } from '../helpers.js';

const names = (page) => page.$$('tbody tr td:first-child').map((td) => td.textContent);

test('confirming deletes the whole row', async () => {
  const page = await openPage('06_patterns', 'deleterow');
  page.$$('button')[1].click();
  await page.until(() => page.$$('tbody tr').length === 2, 'two rows left', 1500);
  expect(names(page)).toEqual(['Ada', 'Katherine']);
  expect(page.$$('button')).toHaveLength(2);
  expect(await (await page.fetch('/contacts')).text()).toBe('Ada, Katherine');
});

test('the DELETE response is a swappable 200', async () => {
  const page = await openPage('06_patterns', 'deleterow');
  const res = await page.fetch('/contacts/3', { method: 'DELETE' });
  expect(res.status).toBe(200);
});

test('cancelling keeps the row', async () => {
  const page = await openPage('06_patterns', 'deleterow', { confirm: false });
  page.$$('button')[0].click();
  await sleep(200);
  expect(names(page)).toEqual(['Ada', 'Grace', 'Katherine']);
  expect(page.htmxRequests()).toHaveLength(0);
});

/* HINT
1. Add hx-target="closest tr" to the <tbody>; the buttons inherit it.
2. return '' (an empty 200) instead of { status: 204 }.
*/

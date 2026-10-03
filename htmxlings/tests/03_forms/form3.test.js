import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('votes carry id and direction', async () => {
  const page = await openPage('03_forms', 'form3');
  page.click('#up');
  await page.until(() => page.text('#score') === '1', 'score 1 after an up vote');
  page.click('#up');
  await page.until(() => page.text('#score') === '2', 'score 2');
  page.click('#down');
  await page.until(() => page.text('#score') === '1', 'score 1 after a down vote');
  const votes = page.htmxRequests().filter((r) => r.path === '/vote').map((r) => r.form);
  expect(votes).toEqual([
    { id: '7', dir: 'up' },
    { id: '7', dir: 'up' },
    { id: '7', dir: 'down' },
  ]);
});

/* HINT
Valid JSON has double-quoted keys and strings, so wrap the attribute in
single quotes: hx-vals='{"id": 7, "dir": "up"}'
*/

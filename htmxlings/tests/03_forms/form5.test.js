import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

const apply = async (page, code) => {
  page.$('input[name=code]').value = code;
  page.submit('form');
};

test('a 422 error message is shown', async () => {
  const page = await openPage('03_forms', 'form5');
  await apply(page, 'FREE');
  await page.until(() => page.$('#result .error'), 'the 422 error message in #result');
  expect(page.text('#result')).toBe('Unknown coupon FREE');
});

test('a good coupon still works', async () => {
  const page = await openPage('03_forms', 'form5');
  await apply(page, 'HTMX10');
  await page.until(() => page.$('#result .ok'), 'the success message');
});

test('other errors still are not swapped', async () => {
  const page = await openPage('03_forms', 'form5');
  const rh = page.window.htmx.config.responseHandling;
  const rule = rh.find((r) => new RegExp(`^${r.code}$`).test('500'));
  expect(rule?.swap, 'a 500 should still not be swapped').toBeFalsy();
  expect(rh.find((r) => new RegExp(`^${r.code}$`).test('204'))?.swap).toBeFalsy();
});

/* HINT
In <head>, before the htmx script:
<meta name="htmx-config" content='{"responseHandling": [
  {"code":"204","swap":false}, {"code":"[23]..","swap":true},
  {"code":"422","swap":true}, {"code":"[45]..","swap":false,"error":true}]}'>
The 422 rule must come before the catch-all [45].. rule.
*/

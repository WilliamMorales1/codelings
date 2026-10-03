import { expect, test } from 'vitest';
import { openPage, sleep } from '../helpers.js';

const count = (page, p) => page.htmxRequests().filter((r) => r.path === p).length;

test('a burst of refresh clicks makes one request', async () => {
  const page = await openPage('02_triggers', 'trigger4');
  for (let i = 0; i < 5; i++) {
    page.click('#refresh');
    await sleep(60);
  }
  await page.until(() => page.text('#prices').startsWith('BTC'), 'prices to show');
  await sleep(200);
  expect(count(page, '/prices')).toBe(1);
});

test('the first click refreshes immediately', async () => {
  const page = await openPage('02_triggers', 'trigger4');
  page.click('#refresh');
  await sleep(150);
  expect(count(page, '/prices'), 'throttle, not delay: the first click should go out at once').toBe(1);
});

test('the coupon can only be claimed once', async () => {
  const page = await openPage('02_triggers', 'trigger4');
  page.click('#claim');
  await page.until(() => page.text('#coupon').includes('HTMX-'), 'a coupon code');
  const code = page.text('#coupon');
  page.click('#claim');
  await sleep(1200);
  page.click('#claim');
  await sleep(200);
  expect(count(page, '/coupon')).toBe(1);
  expect(page.text('#coupon')).toBe(code);
});

/* HINT
Name the event, then the modifier: hx-trigger="click throttle:1s" and
hx-trigger="click once".
*/

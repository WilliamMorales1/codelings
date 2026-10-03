import { expect, test } from 'vitest';
import { openPage, sleep } from '../helpers.js';

test('the notice lingers while fading, then goes', async () => {
  const page = await openPage('04_swapping', 'swapdelay1');
  page.click('button');
  await page.until(() => page.$('#notice.htmx-swapping'), '#notice to get the htmx-swapping class');
  await sleep(150);
  expect(page.$('#notice'), 'still there 150ms into the fade').not.toBeNull();
  await page.until(() => !page.$('#notice'), '#notice to be removed', 1500);
  expect(page.text('p')).toBe('Nothing else to see.');
});

/* HINT
Add a swap delay: hx-swap="outerHTML swap:300ms".
*/

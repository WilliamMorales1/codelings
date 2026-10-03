import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('the button toggles instead of nesting', async () => {
  const page = await openPage('04_swapping', 'inner1');
  page.click('button');
  await page.until(() => page.$('button.unfollow'), 'an Unfollow button');
  expect(page.$$('button')).toHaveLength(1);
  expect(page.$('button button')).toBeNull();
  await page.idle();
  page.click('button');
  await page.until(() => page.$('button.follow'), 'a Follow button again');
  expect(page.$$('button')).toHaveLength(1);
  expect(page.text('button')).toBe('Follow');
});

/* HINT
Add hx-swap="outerHTML" to the first button. The server's buttons
already carry it, so the toggle keeps working after the first swap.
*/

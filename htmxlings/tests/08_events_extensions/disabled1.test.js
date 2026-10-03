import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('the button is disabled while posting, and back after', async () => {
  const page = await openPage('08_events_extensions', 'disabled1');
  page.submit('form');
  await page.until(() => page.$('button').disabled, 'the button to be disabled', 200);
  await page.until(() => page.$('#ok'), 'the order confirmation');
  await page.until(() => !page.$('button').disabled, 'the button to be enabled again');
});

/* HINT
Add hx-disabled-elt="find button" to the <form>.
*/

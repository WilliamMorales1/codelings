import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('the spinner shows during the request and hides after', async () => {
  const page = await openPage('08_events_extensions', 'indicator1');
  page.click('button');
  await page.until(() => page.$('#spinner.htmx-request'), '#spinner to get htmx-request', 300);
  await page.until(() => page.$('#report'), 'the report');
  await page.until(() => !page.$('#spinner.htmx-request'), 'the spinner to hide again');
});

/* HINT
Add hx-indicator="#spinner" to the button.
*/

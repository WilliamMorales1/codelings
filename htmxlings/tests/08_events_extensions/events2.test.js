import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('the title counts the messages after each check', async () => {
  const page = await openPage('08_events_extensions', 'events2');
  page.click('button');
  await page.until(() => page.$$('#inbox li').length === 2, 'two messages');
  await page.until(() => page.document.title === '(2) Inbox', 'the title "(2) Inbox"', 1000);
  await page.idle();
  page.click('button');
  await page.until(() => page.document.title === '(4) Inbox', 'the title "(4) Inbox"', 1000);
});

/* HINT
Change 'htmx:beforeSwap' to 'htmx:afterSwap'.
*/

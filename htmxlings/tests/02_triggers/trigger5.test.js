import { expect, test } from 'vitest';
import { openPage, sleep } from '../helpers.js';

const key = (page, target, k) =>
  target.dispatchEvent(new page.window.KeyboardEvent('keyup', { key: k, bubbles: true }));

test('"?" typed in any input opens the help', async () => {
  const page = await openPage('02_triggers', 'trigger5');
  key(page, page.$('#compose'), '?');
  await page.until(() => page.$('#help li'), 'the help list inside #help');
});

test('other keys do nothing', async () => {
  const page = await openPage('02_triggers', 'trigger5');
  key(page, page.$('#compose'), 'x');
  key(page, page.document.body, 'Enter');
  await sleep(200);
  expect(page.htmxRequests()).toHaveLength(0);
});

/* HINT
Keep the filter and add the source: hx-trigger="keyup[key=='?'] from:body".
Key events bubble up from the input to the body, where htmx now listens.
*/

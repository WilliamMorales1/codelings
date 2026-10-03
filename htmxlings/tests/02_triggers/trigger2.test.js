import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('stats load without any clicking', async () => {
  const page = await openPage('02_triggers', 'trigger2');
  await page.until(() => page.$('#stats #visitors'), '#visitors inside #stats');
  expect(page.text('#stats')).not.toContain('Loading');
  expect(page.htmxRequests().filter((r) => r.path === '/stats')).toHaveLength(1);
});

/* HINT
Add hx-trigger="load" to the div.
*/

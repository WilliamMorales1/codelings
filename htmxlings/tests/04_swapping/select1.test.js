import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('only the forecast is swapped in', async () => {
  const page = await openPage('04_swapping', 'select1');
  page.click('button');
  await page.until(() => page.$('#weather #forecast'), '#forecast inside #weather');
  expect(page.$('#weather nav')).toBeNull();
  expect(page.$('#weather footer')).toBeNull();
  expect(page.$$('h1')).toHaveLength(1);
  expect(page.text('#weather')).toContain('Sunny');
});

/* HINT
Add hx-select="#forecast" to the button.
*/

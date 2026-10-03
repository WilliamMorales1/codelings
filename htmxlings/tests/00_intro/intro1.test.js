import { expect, test } from 'vitest';
import { openPage, serve } from '../helpers.js';

test('the server answers GET /hello with a fragment', async () => {
  const srv = await serve('00_intro', 'intro1');
  const res = await srv.fetch('/hello');
  expect(res.status).toBe(200);
  expect(await res.text()).toContain('Hello from the server!');
});

test('clicking the button swaps the greeting in', async () => {
  const page = await openPage('00_intro', 'intro1');
  page.click('button');
  await page.until(() => page.text('#greeting').includes('Hello from the server!'), '#greeting to be filled');
});

/* HINT
Change the text the GET /hello route returns in handlers.js to
"Hello from the server!". Then try `npm run serve intro1` to see it in a browser.
*/

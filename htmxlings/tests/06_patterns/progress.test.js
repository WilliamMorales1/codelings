import { expect, test } from 'vitest';
import { openPage, sleep } from '../helpers.js';

const polls = (page) => page.htmxRequests().filter((r) => r.path === '/jobs/progress').length;

test('the bar fills up, then polling stops', async () => {
  const page = await openPage('06_patterns', 'progress');
  page.click('button');
  await page.until(() => page.$('#pct'), 'the progress bar');
  await page.until(() => page.$('#done'), 'the finished message', 3000);
  const n = polls(page);
  expect(n).toBe(4);
  await sleep(600);
  expect(polls(page), 'no more polling once the job is done').toBe(n);
});

/* HINT
return { status: 286, body: html`<p id="done">Export finished!</p>` };
*/

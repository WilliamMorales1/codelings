import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('the Mars button fills the Mars row', async () => {
  const page = await openPage('01_basics', 'target1');
  page.$$('li button')[2].click();
  await page.until(() => page.$$('.details')[2].textContent.includes('mars'), 'the third .details to mention mars');
  expect(page.$$('.details')[0].textContent).toBe('');
});

test('every button targets its own row', async () => {
  const page = await openPage('01_basics', 'target1');
  for (const b of page.$$('li button')) b.click();
  await page.until(() => page.$$('.details').every((d) => d.textContent), 'every .details to be filled');
  expect(page.$$('.details').map((d) => d.textContent)).toEqual(['mercury: 0 moons', 'venus: 0 moons', 'mars: 2 moons']);
});

/* HINT
hx-target="next .details" means "the next .details element after me in
the document". `closest li` would also work, but then the response would
replace the whole <li> contents, button and all.
*/

import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('the form posts JSON', async () => {
  const page = await openPage('08_events_extensions', 'jsonenc1');
  page.submit('form');
  await page.until(() => page.$('#saved'), 'the saved message');
  expect(page.text('#saved')).toBe('Saved Rex (good, fluffy)');
  const req = page.htmxRequests()[0];
  expect(req.headers['content-type']).toMatch(/^application\/json/);
  expect(JSON.parse(req.body)).toEqual({ name: 'Rex', tags: ['good', 'fluffy'] });
});

/* HINT
Add hx-ext="json-enc" to the <form>.
*/

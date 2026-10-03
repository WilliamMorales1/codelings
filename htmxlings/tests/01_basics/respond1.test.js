import { expect, test } from 'vitest';
import { openPage, serve } from '../helpers.js';

test('GET /contacts is just the <li> items', async () => {
  const srv = await serve('01_basics', 'respond1');
  const body = (await (await srv.fetch('/contacts')).text()).trim();
  expect(body).not.toMatch(/<html|<body|<nav|<h1|<ul/i);
  expect(body.match(/<li>/g)).toHaveLength(3);
});

test('the list holds three contacts and nothing else', async () => {
  const page = await openPage('01_basics', 'respond1');
  page.click('button');
  await page.until(() => page.$$('#list li').length === 3, 'three <li> in #list');
  expect([...page.$('#list').children].map((c) => c.tagName)).toEqual(['LI', 'LI', 'LI']);
  expect(page.$$('h1')).toHaveLength(1);
});

/* HINT
`items()` already builds the <li> list. Return html`${items()}` (or just
items() wrapped in html``) instead of the layout.
*/

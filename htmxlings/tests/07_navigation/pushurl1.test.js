import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

test('searching puts the query in the address bar', async () => {
  const page = await openPage('07_navigation', 'pushurl1');
  page.$('input[name=q]').value = 'web';
  page.submit('form');
  await page.until(() => page.$('#results li'), 'search results');
  await page.idle();
  expect(page.window.location.pathname + page.window.location.search).toBe('/search?q=web');
});

test('Back returns to the empty search page', async () => {
  const page = await openPage('07_navigation', 'pushurl1');
  page.$('input[name=q]').value = 'rest';
  page.submit('form');
  await page.until(() => page.window.location.search === '?q=rest', 'the pushed URL');
  await page.idle();
  page.window.history.back();
  await page.until(() => page.window.location.pathname === '/' && !page.$('#results li'), 'the original page');
});

test('the pushed URL is a real page', async () => {
  const page = await openPage('07_navigation', 'pushurl1', { pathname: '/search?q=hyper' });
  expect(page.text('#results')).toBe('Hypermedia Systems');
  expect(page.$('form')).not.toBeNull();
});

/* HINT
Add hx-push-url="true" to the <form>.
*/

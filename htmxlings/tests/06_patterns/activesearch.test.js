import { expect, test } from 'vitest';
import { openPage, serve, sleep } from '../helpers.js';

const names = async (q) => {
  const srv = await serve('06_patterns', 'activesearch');
  const body = await (await srv.fetch('/search', { form: { q } })).text();
  return [...body.matchAll(/<tr><td>([^<]*)<\/td>/g)].map((m) => m[1]);
};

test('the server filters by name and email, ignoring case', async () => {
  expect(await names('GRACE')).toEqual(['Grace Hopper']);
  expect(await names('nasa')).toEqual(['Katherine Johnson']);
  expect(await names('')).toHaveLength(5);
  expect(await names('zzz')).toEqual([]);
});

test('typing searches after a pause, once', async () => {
  const page = await openPage('06_patterns', 'activesearch');
  page.type('input', 'al');
  await page.until(() => page.$$('#results tr').length > 0, 'results to appear', 3000);
  await sleep(500);
  const searches = page.htmxRequests().filter((r) => r.path === '/search');
  expect(searches.map((r) => r.form.q)).toEqual(['al']);
  expect(page.$$('#results tr td:first-child').map((td) => td.textContent)).toEqual([
    'Ada Lovelace',
    'Alan Turing',
  ]);
});

/* HINT
1. hx-trigger="input changed delay:300ms" (add ", search" to also catch
   the clear button of a search input in real browsers).
2. const q = (form.q ?? '').toLowerCase();
   contacts.filter((c) => (c.name + ' ' + c.email).toLowerCase().includes(q))
*/

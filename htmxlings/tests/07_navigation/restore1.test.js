import { expect, test } from 'vitest';
import { openPage, serve } from '../helpers.js';

const get = async (headers = {}) => {
  const srv = await serve('07_navigation', 'restore1');
  return srv.fetch('/tab/2', { headers });
};

test('a direct visit gets the full page', async () => {
  const body = await (await get()).text();
  expect(body).toMatch(/<html/);
  expect(body).toContain('Detailed specs.');
});

test('htmx tab clicks get the fragment, with Vary: HX-Request', async () => {
  const res = await get({ 'HX-Request': 'true' });
  expect(res.headers.get('vary')).toMatch(/HX-Request/i);
  const body = await res.text();
  expect(body).not.toMatch(/<html|<nav/);
  expect(body).toContain('Detailed specs.');
});

test('history restores get the full page', async () => {
  const body = await (await get({ 'HX-Request': 'true', 'HX-History-Restore-Request': 'true' })).text();
  expect(body).toMatch(/<nav/);
});

test('Back after a history cache miss rebuilds the whole page', async () => {
  const page = await openPage('07_navigation', 'restore1', { pathname: '/tab/1' });
  expect(page.$('nav'), 'visiting /tab/1 directly should show the full page').not.toBeNull();
  page.click('nav button:nth-of-type(3)');
  await page.until(() => page.window.location.pathname === '/tab/3', 'the URL /tab/3');
  await page.idle();
  expect(page.$$('nav')).toHaveLength(1);
  page.window.localStorage.clear();
  page.window.history.back();
  await page.until(() => page.window.location.pathname === '/tab/1' && page.text('#tab').includes('Overview'), 'tab 1 restored');
  await page.idle();
  expect(page.$('nav'), 'the restored page lost its nav').not.toBeNull();
  expect(page.$$('h1')).toHaveLength(1);
});

/* HINT
const fragment = headers['hx-request'] === 'true' && headers['hx-history-restore-request'] !== 'true';
return { headers: { Vary: 'HX-Request' }, body: fragment ? tab(params.n) : layout(params.n) };
*/

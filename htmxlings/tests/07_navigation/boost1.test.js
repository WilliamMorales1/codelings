import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

const go = async (page, href, title) => {
  await page.idle();
  page.click(`nav a[href="${href}"]`);
  await page.until(() => page.document.title === title, `the title to become "${title}"`);
  await page.idle();
};

test('links load over htmx, in the same window', async () => {
  const page = await openPage('07_navigation', 'boost1');
  page.window.stillHere = true;
  await go(page, '/about', 'About');
  expect(page.window.stillHere, 'a full page load would have reset the window').toBe(true);
  expect(page.window.location.pathname).toBe('/about');
  expect(page.text('h1')).toBe('About');
  const req = page.htmxRequests().at(-1);
  expect(req.headers['hx-boosted']).toBe('true');
});

test('boosting keeps working on the next page, and back works', async () => {
  const page = await openPage('07_navigation', 'boost1');
  await go(page, '/about', 'About');
  await go(page, '/contact', 'Contact');
  expect(page.$$('nav')).toHaveLength(1);
  page.window.history.back();
  await page.until(() => page.window.location.pathname === '/about' && page.text('h1') === 'About', 'back to /about');
});

test('every page boosts its nav', async () => {
  for (const p of ['/', '/about', '/contact']) {
    const page = await openPage('07_navigation', 'boost1', { pathname: p });
    expect(page.$('nav').getAttribute('hx-boost'), `hx-boost on the nav of ${p}`).toBe('true');
  }
});

/* HINT
<nav hx-boost="true"> on each of the three pages. Links inside inherit it.
*/

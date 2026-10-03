import { expect, test } from 'vitest';
import { openPage, serve } from '../helpers.js';

const good = { user: 'admin', password: 'hunter2' };

test('htmx logins get 200 + HX-Redirect', async () => {
  const srv = await serve('05_headers', 'redirect1');
  const res = await srv.fetch('/login', { form: good, redirect: 'manual', headers: { 'HX-Request': 'true' } });
  expect(res.status).toBe(200);
  expect(res.headers.get('hx-redirect')).toBe('/dashboard');
});

test('plain form posts still get a 302', async () => {
  const srv = await serve('05_headers', 'redirect1');
  const res = await srv.fetch('/login', { form: good, redirect: 'manual' });
  expect(res.status).toBe(302);
  expect(res.headers.get('location')).toBe('/dashboard');
});

test('in the page, htmx navigates instead of nesting the dashboard', async () => {
  const page = await openPage('05_headers', 'redirect1');
  const loc = { href: page.window.location.href, reload() {} };
  page.window.htmx.location = loc;
  page.$('input[name=user]').value = 'admin';
  page.$('input[name=password]').value = 'hunter2';
  page.submit('form');
  await page.until(() => page.htmxRequests().length === 1, 'the login request');
  await page.until(() => loc.href === '/dashboard' || page.$('#dashboard'), 'a redirect or a swap');
  expect(page.$('#message #dashboard'), 'the dashboard ended up inside the login form').toBeNull();
  expect(loc.href).toBe('/dashboard');
});

/* HINT
Before the 302, add:
  if (headers['hx-request'] === 'true') return { headers: { 'HX-Redirect': '/dashboard' } };
*/

import { expect, test } from 'vitest';
import { openPage, serve } from '../helpers.js';

test('errors carry HX-Retarget and HX-Reswap', async () => {
  const srv = await serve('05_headers', 'retarget1');
  const res = await srv.fetch('/comments', { form: { text: '  ' } });
  expect(res.headers.get('hx-retarget')).toBe('#errors');
  expect(res.headers.get('hx-reswap')).toMatch(/^innerHTML/);
});

test('an empty comment shows an error, not a bogus comment', async () => {
  const page = await openPage('05_headers', 'retarget1');
  page.submit('form');
  await page.until(() => page.text('#errors').includes('cannot be empty'), 'the error in #errors');
  expect(page.$('#comments').children).toHaveLength(0);
  await page.idle();
  page.submit('form');
  await page.until(() => page.htmxRequests().length === 2, 'a second attempt');
  await page.idle();
  expect(page.$$('#errors p'), 'innerHTML, so errors do not pile up').toHaveLength(1);
  page.$('input[name=text]').value = 'first!';
  page.submit('form');
  await page.until(() => page.$$('#comments li').length === 1, 'one comment');
});

/* HINT
return { headers: { 'HX-Retarget': '#errors', 'HX-Reswap': 'innerHTML' },
         body: html`<p>A comment cannot be empty.</p>` };
*/

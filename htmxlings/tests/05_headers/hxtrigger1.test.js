import { expect, test } from 'vitest';
import { openPage, serve } from '../helpers.js';

test('POST /contacts sends HX-Trigger: contactAdded', async () => {
  const srv = await serve('05_headers', 'hxtrigger1');
  const res = await srv.fetch('/contacts', { form: { name: 'Katherine' } });
  expect(res.headers.get('hx-trigger')).toBe('contactAdded');
  expect(await res.text()).toContain('<li>Katherine</li>');
});

test('the counter refreshes after adding', async () => {
  const page = await openPage('05_headers', 'hxtrigger1');
  page.$('input[name=name]').value = 'Katherine';
  page.submit('form');
  await page.until(() => page.text('#count') === '3', '#count to become 3');
  expect(page.$$('#contacts li')).toHaveLength(3);
});

/* HINT
return { headers: { 'HX-Trigger': 'contactAdded' }, body: html`<li>${form.name}</li>` };
*/

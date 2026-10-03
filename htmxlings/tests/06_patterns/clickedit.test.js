import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

const edit = async (page) => {
  await page.until(() => page.$('div#contact button'), 'the contact view');
  await page.idle();
  page.click('div#contact button');
  await page.until(() => page.$('form#contact'), 'the edit form');
  await page.idle();
};

test('edit, save, and the view shows the new values', async () => {
  const page = await openPage('06_patterns', 'clickedit');
  await edit(page);
  page.$('input[name=firstName]').value = 'Jane';
  page.$('input[name=email]').value = 'jane@doe.com';
  page.submit('form#contact');
  await page.until(() => page.$('div#contact .first')?.textContent === 'Jane', 'the view with first name Jane');
  expect(page.text('.email')).toBe('jane@doe.com');
  expect(page.text('.last')).toBe('Blow');
  const put = page.htmxRequests().find((r) => r.method === 'PUT');
  expect(put.form).toEqual({ firstName: 'Jane', lastName: 'Blow', email: 'jane@doe.com' });
  const fresh = await (await page.fetch('/contact/1')).text();
  expect(fresh, 'the server should remember the change').toContain('Jane');
});

test('cancel goes back to the unchanged view', async () => {
  const page = await openPage('06_patterns', 'clickedit');
  await edit(page);
  page.$('input[name=firstName]').value = 'Nope';
  page.click('button[type=button]');
  await page.until(() => page.$('div#contact .first'), 'the view again');
  expect(page.text('.first')).toBe('Joe');
  expect(page.$$('#contact')).toHaveLength(1);
});

/* HINT
'PUT /contact/1': ({ form }) => {
  contact.firstName = form.firstName; ...; return view();
}
*/

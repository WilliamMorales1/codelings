import { expect, test } from 'vitest';
import { openPage, serve } from '../helpers.js';

const signup = async (form) => {
  const srv = await serve('03_forms', 'form4');
  return (await srv.fetch('/signup', { form })).text();
};

test('a short username comes back as the form with an error', async () => {
  const body = await signup({ username: 'al', email: 'al@example.com' });
  expect(body).toMatch(/<form/);
  expect(body).toMatch(/class="error"/);
  expect(body).not.toMatch(/welcome/i);
  expect(body).toContain('value="al@example.com"');
});

test('an email without @ is rejected', async () => {
  const body = await signup({ username: 'alice', email: 'alice.example.com' });
  expect(body.match(/class="error"/g)).toHaveLength(1);
  expect(body).toContain('value="alice"');
});

test('in the page, errors replace the form and a fix gets through', async () => {
  const page = await openPage('03_forms', 'form4');
  page.$('input[name=username]').value = 'x';
  page.$('input[name=email]').value = 'nope';
  page.submit('form');
  await page.until(() => page.$$('.error').length === 2, 'two .error messages');
  expect(page.$$('form')).toHaveLength(1);
  expect(page.$('input[name=username]').value).toBe('x');
  await page.idle();
  page.$('input[name=username]').value = 'xavier';
  page.$('input[name=email]').value = 'x@example.com';
  page.submit('form');
  await page.until(() => page.$('#welcome'), '#welcome after a valid signup');
  expect(page.$('form')).toBeNull();
});

/* HINT
Build an `errors` object, and if it has any keys return
signupForm(form, errors) instead of the welcome message. The template
already prints errors and values; html`` escapes them for you.
*/

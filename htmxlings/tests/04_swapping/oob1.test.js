import { expect, test } from 'vitest';
import { openPage } from '../helpers.js';

const add = (page, title) => {
  page.$('input[name=title]').value = title;
  page.submit('form');
};

test('the counter follows the list', async () => {
  const page = await openPage('04_swapping', 'oob1');
  add(page, 'write tests');
  await page.until(() => page.$$('#todos li').length === 1, 'one todo');
  await page.until(() => page.text('#count') === '1 todos', '#count to read "1 todos"');
  await page.idle();
  add(page, 'ship it');
  await page.until(() => page.text('#count') === '2 todos', '#count to read "2 todos"');
  expect(page.$$('#todos li').map((li) => li.textContent)).toEqual(['write tests', 'ship it']);
  expect(page.$('#todos span'), 'the counter should not end up inside the list').toBeNull();
  expect(page.$$('#count')).toHaveLength(1);
  expect(page.$('h1 #count')).not.toBeNull();
});

/* HINT
Return both pieces from the handler:
  html`<li>${form.title}</li>
    <span id="count" hx-swap-oob="true">${todos.length} todos</span>`
*/

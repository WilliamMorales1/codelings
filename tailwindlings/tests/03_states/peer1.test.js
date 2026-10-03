import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('unchecked: the details are hidden', async () => {
  const page = await load('03_states/peer1');
  page.$('#toggle').checked = false;
  page.refresh();
  expect(page.get('#details', 'display')).toBe('none');
});

test('checked: the details are shown', async () => {
  const page = await load('03_states/peer1');
  page.$('#toggle').checked = true;
  page.refresh();
  expect(page.get('#details', 'display'), '#details display with the box ticked').toBe('block');
});

/* HINT
Two fixes: the checkbox needs the `peer` class, and it has to come BEFORE
#details in the markup, because `peer-checked:` compiles to
`.peer:checked ~ *` and `~` only matches later siblings.
*/

import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the avatar is a 48px square', async () => {
  const page = await load('01_utilities/sizing1');
  expect(page.num('#avatar', 'width'), '#avatar width').toBe(48);
  expect(page.num('#avatar', 'height'), '#avatar height').toBe(48);
});

test('the sidebar is 256px and does not shrink', async () => {
  const page = await load('01_utilities/sizing1');
  expect(page.num('#sidebar', 'width'), '#sidebar width').toBe(256);
  expect(page.get('#sidebar', 'flex-shrink'), '#sidebar flex-shrink').toBe('0');
});

test('the copy is capped at 28rem', async () => {
  const page = await load('01_utilities/sizing1');
  expect(page.num('#copy', 'max-width'), '#copy max-width in px').toBe(448);
});

/* HINT
`size-12` is width + height in one. The sidebar needs `w-64` (there is
no `width-64`) plus `shrink-0`, since flex items shrink by default when the
row is short on space. `max-w-md` reads --container-md (28rem).
*/

import { expect, test } from 'vitest';
import { color, load } from '../helpers.js';

test('the layout grid has a 200px column and a flexible one', async () => {
  const page = await load('06_theme/arbitrary1');
  expect(page.get('#layout', 'grid-template-columns'), '#layout grid-template-columns').toBe('200px 1fr');
});

test('the sidebar is 200px wide and #bada55', async () => {
  const page = await load('06_theme/arbitrary1');
  expect(page.num('#sidebar', 'width'), '#sidebar width').toBe(200);
  expect(color(page.get('#sidebar', 'background-color')), '#sidebar background').toBe('#bada55');
});

test('the label is vertical', async () => {
  const page = await load('06_theme/arbitrary1');
  expect(page.get('#label', 'writing-mode')).toBe('vertical-rl');
});

test('the tooltip sits 4px below its parent', async () => {
  const page = await load('06_theme/arbitrary1');
  expect(page.get('#tooltip', 'top')?.replace(/\s+/g, ''), '#tooltip top').toBe('calc(100%+4px)');
});

/* HINT
`grid-cols-[200px_1fr]`, `w-[12.5rem]`, `bg-[#bada55]`,
`[writing-mode:vertical-rl]`, `top-[calc(100%+4px)]`. Tailwind adds the
spaces around + inside calc() for you; a real space would split the class
in two.
*/

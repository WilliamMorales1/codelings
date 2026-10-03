import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('the shell is a flex column at least as tall as the viewport', async () => {
  const page = await load('02_layout/flex2');
  const shell = page.style('#shell');
  expect(shell.get('display')).toBe('flex');
  expect(shell.get('flex-direction'), 'flex-direction').toBe('column');
  expect(shell.get('min-height'), 'min-height').toBe('100vh');
  const h = shell.get('height');
  expect(h === undefined || h === 'auto', `a fixed height (${h}) cuts off long pages; use min-h-screen`).toBe(true);
});

test('main grows into the leftover space', async () => {
  const page = await load('02_layout/flex2');
  expect(page.get('#main', 'flex'), '#main flex').toMatch(/^1( 1 0%)?$/);
});

test('the New button is pushed right with an auto margin', async () => {
  const page = await load('02_layout/flex2');
  expect(page.get('#new', 'margin-left'), '#new margin-left').toBe('auto');
  expect(page.get('#new', 'float') ?? 'none', 'floats are ignored inside flex containers').toBe('none');
});

/* HINT
Shell: `flex min-h-screen flex-col` (h-screen would clip a long page).
Main: `flex-1`. Button: swap `float-right` (which flexbox ignores) for
`ml-auto`.
*/

import { expect, test } from 'vitest';
import { load, readEx } from '../helpers.js';

test.each([
  ['#four', 16],
  ['#eight', 32],
  ['#list', 24],
])('%s hangs by %ipx', async (id, px) => {
  const page = await load('07_components/utility2');
  expect(page.num(id, 'padding-left'), `${id} padding-left`).toBe(px);
  expect(page.num(id, 'text-indent'), `${id} text-indent`).toBe(-px);
});

test('one functional utility, not a list of fixed ones', async () => {
  const css = readEx('07_components/utility2', 'style.css');
  expect(css, 'an @utility hang-* rule').toMatch(/@utility\s+hang-\*\s*\{/);
  expect(css, 'fixed hang-N utilities are gone').not.toMatch(/@utility\s+hang-\d/);
});

/* HINT
  @utility hang-* {
    padding-left: calc(var(--spacing) * --value(--hang-*, integer));
    text-indent: calc(var(--spacing) * --value(--hang-*, integer) * -1);
  }
`list` is looked up as --hang-list; digits match `integer`.
*/

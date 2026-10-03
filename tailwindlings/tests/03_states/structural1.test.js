import { expect, test } from 'vitest';
import { load } from '../helpers.js';

test('odd rows are striped, even rows are not', async () => {
  const page = await load('03_states/structural1');
  const gray = page.theme('--color-gray-50');
  expect(page.get('#r1', 'background-color'), '#r1').toBe(gray);
  expect(page.get('#r3', 'background-color'), '#r3').toBe(gray);
  expect(page.get('#r2', 'background-color'), '#r2').not.toBe(gray);
  expect(page.get('#r4', 'background-color'), '#r4').not.toBe(gray);
});

test('every row but the last has a bottom border', async () => {
  const page = await load('03_states/structural1');
  for (const id of ['#r1', '#r2', '#r3']) expect(page.num(id, 'border-bottom-width'), `${id} border-bottom`).toBe(1);
  expect(page.num('#r4', 'border-bottom-width'), '#r4 (last) border-bottom').toBe(0);
});

test('the stripes follow the rows when one is added', async () => {
  const page = await load('03_states/structural1');
  const tbody = page.$('tbody');
  const extra = page.$('#r4').cloneNode(true);
  extra.id = 'r5';
  tbody.appendChild(extra);
  page.refresh();
  try {
    expect(page.get('#r5', 'background-color'), 'new 5th row is odd').toBe(page.theme('--color-gray-50'));
    expect(page.num('#r4', 'border-bottom-width'), '#r4 is no longer last').toBe(1);
    expect(page.num('#r5', 'border-bottom-width'), '#r5 is last').toBe(0);
  } finally {
    extra.remove();
    page.refresh();
  }
});

/* HINT
Give every row the same classes and let the variants decide:
`odd:bg-gray-50 not-last:border-b not-last:border-gray-200`. Hand-placed
classes break as soon as a row is inserted.
*/

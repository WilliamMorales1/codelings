import { expect, expectTypeOf, it } from 'vitest';
import { prices, total } from '@ex/00_intro/intro2.ts';

it('adds the prices as numbers', () => {
  expect(total(prices)).toBe(12);
});

it('keeps the annotations', () => {
  expectTypeOf(prices).toEqualTypeOf<number[]>();
});

/* HINT
The error is on the `prices` line: "Type 'string' is not assignable to type
'number'". At runtime JavaScript would happily build [3, 4, "5"] and then
compute 7 + "5" = "75" — exactly the bug the annotation exists to catch.
*/

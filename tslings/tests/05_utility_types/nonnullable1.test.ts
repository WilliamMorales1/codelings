import { expect, expectTypeOf, it } from 'vitest';
import { compact } from '@ex/05_utility_types/nonnullable1.ts';

it('drops null and undefined but keeps falsy values', () => {
  expect(compact([1, null, 0, undefined, 3])).toEqual([1, 0, 3]);
  expect(compact(['', null])).toEqual(['']);
});

it('returns the non-nullable element type', () => {
  expectTypeOf(compact([1, null, undefined])).toEqualTypeOf<number[]>();
  expectTypeOf(compact(['a', undefined])).toEqualTypeOf<string[]>();
});

/* HINT
Return type `NonNullable<T>[]`. `x != null` (two equals signs) is true for
everything except null AND undefined; `x !== null` misses undefined.
Don't use `Boolean` as the filter — it would also drop 0 and ''.
*/

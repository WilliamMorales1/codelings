import { expect, expectTypeOf, it } from 'vitest';
import { alphabetical, FRUITS, sorted } from '@ex/03_objects/readonly1.ts';

it('sorts', () => {
  expect(alphabetical()).toEqual(['apple', 'fig', 'pear']);
});

it('leaves the input alone', () => {
  const xs = ['b', 'a'];
  expect(sorted(xs)).toEqual(['a', 'b']);
  expect(xs).toEqual(['b', 'a']);
  expect(FRUITS).toEqual(['pear', 'apple', 'fig']);
});

it('takes a readonly array', () => {
  expectTypeOf(sorted).parameter(0).toEqualTypeOf<readonly string[]>();
});

/* HINT
Parameter type: `xs: readonly string[]`. Then `xs.sort()` stops compiling —
the type system just found the mutation for you. `xs.toSorted()` (ES2023)
returns a sorted copy; `[...xs].sort()` does the same in older code.
*/

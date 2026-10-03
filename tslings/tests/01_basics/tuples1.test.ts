import { expect, expectTypeOf, it } from 'vitest';
import { parseEntry, total } from '@ex/01_basics/tuples1.ts';

it('parses key=value', () => {
  expect(parseEntry('apples=3')).toEqual(['apples', 3]);
  expect(total(['a=1', 'b=2', 'c=39'])).toBe(42);
});

it('returns a [string, number] pair', () => {
  expectTypeOf(parseEntry).returns.toEqualTypeOf<[string, number]>();
});

/* HINT
Annotate the return type: `function parseEntry(line: string): [string, number]`.
Labels are allowed and show up in editor tooltips: `[key: string, value: number]`.
`key` from the destructuring is `string | undefined`; `key ?? ''` turns it
into a string.
*/

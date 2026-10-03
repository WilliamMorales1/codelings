import { expect, expectTypeOf, it } from 'vitest';
import { double, parse } from '@ex/04_functions/overloads1.ts';

it('parses one or many', () => {
  expect(parse('42')).toBe(42);
  expect(parse(['1', '2'])).toEqual([1, 2]);
  expect(double('21')).toBe(42);
});

it('returns the matching type', () => {
  expectTypeOf(parse('42')).toEqualTypeOf<number>();
  expectTypeOf(parse(['1'])).toEqualTypeOf<number[]>();
  // @ts-expect-error numbers are not accepted
  parse(42);
});

/* HINT
Add two lines, ending in `;`, directly above the implementation:
  export function parse(input: string): number;
  export function parse(input: string[]): number[];
Overloads are tried top to bottom and the first match wins.
*/

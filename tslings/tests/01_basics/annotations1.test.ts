import { expect, expectTypeOf, it } from 'vitest';
import { formatPrice, isAdult, repeat } from '@ex/01_basics/annotations1.ts';

it('still works at runtime', () => {
  expect(formatPrice(1999, 'EUR')).toBe('19.99 EUR');
  expect(isAdult(18)).toBe(true);
  expect(isAdult(17)).toBe(false);
  expect(repeat('ab', 3)).toBe('ababab');
});

it('has precise signatures', () => {
  expectTypeOf(formatPrice).toEqualTypeOf<(cents: number, currency: string) => string>();
  expectTypeOf(isAdult).toEqualTypeOf<(age: number) => boolean>();
  expectTypeOf(repeat).toEqualTypeOf<(text: string, times: number) => string>();
});

/* HINT
Syntax is `name: type` after each parameter and `): type {` for the return:
  function isAdult(age: number): boolean { ... }
The primitive types are lowercase: string, number, boolean. (`String` and
`Number` are the wrapper objects — almost never what you want.)
*/

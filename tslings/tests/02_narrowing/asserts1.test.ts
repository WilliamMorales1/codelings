import { expect, expectTypeOf, it } from 'vitest';
import { assert, assertIsDefined, parsePort } from '@ex/02_narrowing/asserts1.ts';

it('parses a port', () => {
  expect(parsePort({ PORT: '8080' })).toBe(8080);
  expect(() => parsePort({})).toThrow('PORT is not set');
  expect(() => parsePort({ PORT: 'http' })).toThrow('bad PORT: http');
});

it('narrows after the call', () => {
  const maybe = ['x'][0];
  assertIsDefined(maybe, 'first');
  expectTypeOf(maybe).toEqualTypeOf<string>();

  const v: string | number = Math.random() > 2 ? 1 : 'one';
  assert(typeof v === 'string', 'not a string');
  expectTypeOf(v).toEqualTypeOf<string>();
});

/* HINT
Replace the `: void` return types:
  function assert(condition: unknown, message: string): asserts condition
  function assertIsDefined<T>(value: T, name: string): asserts value is NonNullable<T>
NonNullable<T> removes null and undefined from T.
*/

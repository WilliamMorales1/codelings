import { expect, expectTypeOf, it } from 'vitest';
import { longest, pluck } from '@ex/04_functions/generics1.ts';

const users = [
  { name: 'Ada', age: 36 },
  { name: 'Grace', age: 85 },
];

it('finds the longest', () => {
  expect(longest('ab', 'abc')).toBe('abc');
  expect(longest([1, 2], [3])).toEqual([1, 2]);
  expectTypeOf(longest([1, 2], [3])).toEqualTypeOf<number[]>();
  // @ts-expect-error numbers have no length
  longest(1, 2);
});

it('plucks typed properties', () => {
  expect(pluck(users, 'age')).toEqual([36, 85]);
  expectTypeOf(pluck(users, 'age')).toEqualTypeOf<number[]>();
  expectTypeOf(pluck(users, 'name')).toEqualTypeOf<string[]>();
  // @ts-expect-error users have no email
  pluck(users, 'email');
});

/* HINT
  function longest<T extends { length: number }>(a: T, b: T): T
  function pluck<T, K extends keyof T>(items: T[], key: K): T[K][]
*/

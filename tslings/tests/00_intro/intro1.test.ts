import { expect, expectTypeOf, it } from 'vitest';
import { greet } from '@ex/00_intro/intro1.ts';

it('greets by name', () => {
  expect(greet('Ada')).toBe('Hello, Ada!');
});

it('takes a string and returns a string', () => {
  expectTypeOf(greet).toEqualTypeOf<(name: string) => string>();
});

/* HINT
The greeting is missing its exclamation mark.
*/

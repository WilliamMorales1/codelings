import { expect, expectTypeOf, it } from 'vitest';
import { formatId, type UserId } from '@ex/01_basics/unions1.ts';

it('formats numeric ids', () => {
  expect(formatId(42)).toBe('#42');
});

it('keeps string ids', () => {
  expect(formatId('u_42')).toBe('u_42');
});

it('UserId is string | number', () => {
  expectTypeOf<UserId>().toEqualTypeOf<string | number>();
});

/* HINT
Change `UserId` to `string | number`. Then `id.startsWith` stops compiling,
because numbers have no startsWith. Check `typeof id === 'number'` first;
after that `if`, TypeScript knows id is a string (this is "narrowing",
chapter 02).
*/

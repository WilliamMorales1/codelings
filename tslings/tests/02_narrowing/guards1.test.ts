import { expect, expectTypeOf, it } from 'vitest';
import { isUser, userNames, type User } from '@ex/02_narrowing/guards1.ts';

it('picks out users', () => {
  const input = [{ id: 1, name: 'Ada' }, null, 'Bob', { id: 2 }, { id: 3, name: 'Grace' }];
  expect(userNames(input)).toEqual(['Ada', 'Grace']);
});

it('checks field types, not just presence', () => {
  expect(isUser({ id: '1', name: 'Ada' })).toBe(false);
  expect(isUser({ id: 1, name: 42 })).toBe(false);
});

it('is a type predicate', () => {
  const x: unknown = { id: 1, name: 'Ada' };
  if (isUser(x)) expectTypeOf(x).toEqualTypeOf<User>();
  expectTypeOf(isUser).guards.toEqualTypeOf<User>();
});

/* HINT
Signature: `function isUser(value: unknown): value is User`.
After `'id' in value`, TypeScript lets you read `value.id` (as unknown), so
you can continue with `&& typeof value.id === 'number'`, and the same for name.
*/

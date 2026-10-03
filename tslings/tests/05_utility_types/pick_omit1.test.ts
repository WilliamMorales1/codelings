import { expect, expectTypeOf, it } from 'vitest';
import { createUser, toPreview, type NewUser, type User, type UserPreview } from '@ex/05_utility_types/pick_omit1.ts';

it('creates and previews users', () => {
  const u = createUser({ displayName: 'Ada', email: 'ada@example.com' });
  expect(u.createdAt).toBeInstanceOf(Date);
  expect(toPreview(u)).toEqual({ id: u.id, displayName: 'Ada' });
});

it('derives from User', () => {
  expectTypeOf<UserPreview>().toEqualTypeOf<Pick<User, 'id' | 'displayName'>>();
  expectTypeOf<NewUser>().toEqualTypeOf<{ displayName: string; email: string }>();
});

/* HINT
  export type UserPreview = Pick<User, 'id' | 'displayName'>;
  export type NewUser = Omit<User, 'id' | 'createdAt'>;
Then toPreview returns `{ id: u.id, displayName: u.displayName }`.
*/

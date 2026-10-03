import { expect, it } from 'vitest';
import { updateUser, type User } from '@ex/05_utility_types/partial1.ts';

const ada: User = { id: 1, name: 'Ada', email: 'ada@example.com', admin: false };

it('changes only what is given', () => {
  expect(updateUser(ada, { admin: true })).toEqual({ ...ada, admin: true });
  expect(updateUser(ada, { name: 'Ada L.', email: 'al@example.com' }).name).toBe('Ada L.');
});

it('never changes the id', () => {
  // @ts-expect-error id is not updatable
  updateUser(ada, { id: 2 });
});

/* HINT
`Partial<User>` gets you the "any subset" part. Wrap the inside in
`Omit<User, 'id'>` to drop id first: `Partial<Omit<User, 'id'>>`.
*/

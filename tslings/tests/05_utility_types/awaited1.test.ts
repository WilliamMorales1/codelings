import { expect, expectTypeOf, it } from 'vitest';
import { fetchUser, isReader, type User } from '@ex/05_utility_types/awaited1.ts';

it('checks roles of a fetched user', async () => {
  expect(isReader(await fetchUser(1))).toBe(true);
});

it('User is the resolved value', () => {
  expectTypeOf<User>().toEqualTypeOf<{ id: number; name: string; roles: string[] }>();
});

/* HINT
`export type User = Awaited<ReturnType<typeof fetchUser>>;`
*/

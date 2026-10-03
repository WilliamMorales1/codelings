// partial1 — Partial
//
// Utility types are generic types shipped with TypeScript that build new
// types from old ones. `Partial<T>` makes every property of T optional —
// exactly the shape of "the fields you want to change".
//
// Task: `updateUser` takes only the fields to change. Its `changes`
// parameter should accept any subset of User's fields EXCEPT `id`, which
// must never change. Combine two utility types (Omit is next exercise's
// topic, but go ahead).

export interface User {
  id: number;
  name: string;
  email: string;
  admin: boolean;
}

export function updateUser(user: User, changes: Partial<Omit<User, 'id'>>): User {
  return { ...user, ...changes };
}

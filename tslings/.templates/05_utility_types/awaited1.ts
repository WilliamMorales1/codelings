// awaited1 — Awaited
//
// An async function's return type is a Promise. `ReturnType` gives you that
// Promise, not what it resolves to. `Awaited<T>` unwraps promises (even
// nested ones), the same way `await` does.
//
// Task: fix `User` so it's the resolved value of `fetchUser`, not a promise.
//

export async function fetchUser(id: number) {
  return { id, name: `user${id}`, roles: ['reader'] };
}

export type User = ReturnType<typeof fetchUser>;

export function isReader(user: User): boolean {
  return user.roles.includes('reader');
}

// fetch1 — Typing JSON from the network
//
// `await res.json()` is typed `Promise<any>`, and `as User` is a promise to
// the compiler that nobody checks. When the API changes, the bad data flows
// through your program and blows up somewhere far away, or not at all.
//
// The safe pattern: treat the body as `unknown`, and *prove* its shape with
// a parser that either returns a real User or throws — at the boundary,
// where the error message can still say what went wrong.
//
// Task:
//   - parseUser(data: unknown): User — throw an Error mentioning the bad
//     field if data isn't a User (id: number, name: string, email: string).
//   - fetchUser — throw on non-2xx responses (`HTTP 404`), and use parseUser
//     instead of the cast.
// The fetch function is passed in so the tests can fake the network.

export interface User {
  id: number;
  name: string;
  email: string;
}

function isRecord(x: unknown): x is Record<string, unknown> {
  return typeof x === 'object' && x !== null && !Array.isArray(x);
}

export function parseUser(data: unknown): User {
  if (!isRecord(data)) throw new Error('user: expected an object');
  const { id, name, email } = data;
  if (typeof id !== 'number') throw new Error('user.id: expected a number');
  if (typeof name !== 'string') throw new Error('user.name: expected a string');
  if (typeof email !== 'string') throw new Error('user.email: expected a string');
  return { id, name, email };
}

export async function fetchUser(id: number, fetchFn: typeof fetch = fetch): Promise<User> {
  const res = await fetchFn(`https://api.example.com/users/${id}`);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const body: unknown = await res.json();
  return parseUser(body);
}

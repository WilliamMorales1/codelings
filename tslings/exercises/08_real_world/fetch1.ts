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
//

export interface User {
  id: number;
  name: string;
  email: string;
}

export function parseUser(data: any): User {
  return data;
}

export async function fetchUser(id: number, fetchFn: typeof fetch = fetch): Promise<User> {
  const res = await fetchFn(`https://api.example.com/users/${id}`);
  return (await res.json()) as User;
}

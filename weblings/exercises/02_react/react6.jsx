// react6.jsx
//
// useEffect: fetching data, dependencies and cleanup
//
// Effects run after render. Three rules keep them sane:
//   - list what the effect reads in the dependency array (`[id]`), or it runs
//     after *every* render -- and an effect that sets state then loops forever
//   - the effect function must not be `async` (it may only return a cleanup
//     function); start a promise chain or call an inner async function instead
//   - return a cleanup that cancels the work, so a slow response for an old
//     `id` can never overwrite the data for the current one. For fetch, that
//     is an AbortController: `fetch(url, { signal })` then `controller.abort()`.
//
// Task: UserCard({ id }) fetches `/api/users/<id>`.
//   - while loading (including after `id` changes) it shows <p>Loading...</p>
//   - then <h2>{user.name}</h2>
//   - a non-2xx response or network error shows <p role="alert">Error: ...</p>
//   - changing `id` or unmounting aborts the request in flight

import { useEffect, useState } from 'react';

export function UserCard({ id }) {
  const [user, setUser] = useState(null);

  useEffect(async () => {
    const res = await fetch(`/api/users/${id}`);
    setUser(await res.json());
  });

  if (!user) return <p>Loading...</p>;
  return <h2>{user.name}</h2>;
}

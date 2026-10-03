// react6.jsx -- reference solution.

import { useEffect, useState } from 'react';

export function UserCard({ id }) {
  const [user, setUser] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    const controller = new AbortController();
    setUser(null);
    setError(null);
    fetch(`/api/users/${id}`, { signal: controller.signal })
      .then((res) => {
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        return res.json();
      })
      .then(setUser)
      .catch((err) => {
        if (err.name !== 'AbortError') setError(err);
      });
    return () => controller.abort();
  }, [id]);

  if (error) return <p role="alert">Error: {error.message}</p>;
  if (!user) return <p>Loading...</p>;
  return <h2>{user.name}</h2>;
}

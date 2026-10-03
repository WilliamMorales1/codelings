// @vitest-environment jsdom
import { act, cleanup, render, screen } from '@testing-library/react';
import { afterEach, beforeEach, expect, test, vi } from 'vitest';
import { UserCard } from '@ex/02_react/react6.jsx';

// Each fetch call waits until the test answers it, and rejects on abort like the real thing.
let calls;
beforeEach(() => {
  calls = [];
  vi.stubGlobal(
    'fetch',
    vi.fn((url, { signal } = {}) => {
      let respond;
      const promise = new Promise((resolve, reject) => {
        respond = (status, body) => resolve({ ok: status < 300, status, json: async () => body });
        signal?.addEventListener('abort', () => reject(new DOMException('aborted', 'AbortError')));
      });
      calls.push({ url, signal, respond });
      return promise;
    }),
  );
});

afterEach(() => {
  cleanup();
  vi.unstubAllGlobals();
});

const answer = (i, status, body) => act(async () => calls[i].respond(status, body));

test('shows Loading... and then the user', async () => {
  render(<UserCard id={1} />);
  expect(screen.getByText('Loading...')).toBeTruthy();
  await answer(0, 200, { name: 'Ada' });
  expect(screen.getByRole('heading').textContent).toBe('Ada');
});

test('fetches /api/users/<id> exactly once per id', async () => {
  render(<UserCard id={1} />);
  await answer(0, 200, { name: 'Ada' });
  await act(async () => {});
  expect(fetch).toHaveBeenCalledTimes(1);
  expect(calls[0].url).toBe('/api/users/1');
});

test('an HTTP error is shown', async () => {
  render(<UserCard id={404} />);
  await answer(0, 404, {});
  expect(screen.getByRole('alert').textContent).toMatch(/Error: .*404/);
});

test('changing id aborts the old request and never shows stale data', async () => {
  const { rerender } = render(<UserCard id={1} />);
  rerender(<UserCard id={2} />);
  expect(calls.map((c) => c.url)).toEqual(['/api/users/1', '/api/users/2']);
  expect(calls[0].signal?.aborted).toBe(true);
  await answer(1, 200, { name: 'Grace' });
  await answer(0, 200, { name: 'Ada' });
  expect(screen.getByRole('heading').textContent).toBe('Grace');
});

test('switching id shows Loading... again', async () => {
  const { rerender } = render(<UserCard id={1} />);
  await answer(0, 200, { name: 'Ada' });
  rerender(<UserCard id={2} />);
  expect(screen.getByText('Loading...')).toBeTruthy();
});

test('unmounting aborts the request', () => {
  const { unmount } = render(<UserCard id={1} />);
  unmount();
  expect(calls[0].signal?.aborted).toBe(true);
});

/* HINT
Use a plain arrow for the effect and `[id]` as dependencies:
    useEffect(() => {
      const controller = new AbortController();
      setUser(null);
      setError(null);
      fetch(`/api/users/${id}`, { signal: controller.signal })
        .then((res) => { if (!res.ok) throw new Error(`HTTP ${res.status}`); return res.json(); })
        .then(setUser)
        .catch((err) => { if (err.name !== 'AbortError') setError(err); });
      return () => controller.abort();
    }, [id]);
Add an `error` state and render it before the loading check.
*/

import { expect, test } from 'vitest';
import { fetchAll, fetchJson } from '@ex/01_node/node8.js';

// A fake fetch: `/slow/<ms>` answers after <ms>, `/status/<n>` answers with status n,
// and an aborted signal rejects the way real fetch does.
function fakeFetch() {
  const stats = { inFlight: 0, maxInFlight: 0, calls: 0 };
  const fn = (url, { signal } = {}) =>
    new Promise((resolve, reject) => {
      stats.calls++;
      stats.inFlight++;
      stats.maxInFlight = Math.max(stats.maxInFlight, stats.inFlight);
      const status = Number(url.match(/\/status\/(\d+)/)?.[1] ?? 200);
      const ms = Number(url.match(/\/slow\/(\d+)/)?.[1] ?? 20);
      const timer = setTimeout(() => {
        stats.inFlight--;
        resolve({ ok: status < 300, status, json: async () => ({ url }) });
      }, ms);
      signal?.addEventListener('abort', () => {
        clearTimeout(timer);
        stats.inFlight--;
        reject(signal.reason);
      });
      if (signal?.aborted) signal.dispatchEvent(new Event('abort'));
    });
  return { fn, stats };
}

test('fetchJson returns the parsed body', async () => {
  const { fn } = fakeFetch();
  await expect(fetchJson('/users/1', { fetchFn: fn })).resolves.toEqual({ url: '/users/1' });
});

test('fetchJson rejects non-2xx responses', async () => {
  const { fn } = fakeFetch();
  await expect(fetchJson('/status/404', { fetchFn: fn })).rejects.toThrow(/404/);
});

test('fetchJson gives up after timeoutMs', async () => {
  const { fn } = fakeFetch();
  const started = Date.now();
  const err = await fetchJson('/slow/2000', { timeoutMs: 50, fetchFn: fn }).catch((e) => e);
  expect(err?.name).toBe('TimeoutError');
  expect(Date.now() - started).toBeLessThan(1000);
});

test("fetchJson stops when the caller's signal aborts", async () => {
  const { fn } = fakeFetch();
  const ctrl = new AbortController();
  const pending = fetchJson('/slow/2000', { signal: ctrl.signal, fetchFn: fn });
  setTimeout(() => ctrl.abort(), 20);
  const err = await pending.catch((e) => e);
  expect(err?.name).toBe('AbortError');
});

test('fetchAll runs requests concurrently and keeps order', async () => {
  const { fn, stats } = fakeFetch();
  const urls = ['/slow/60/a', '/slow/10/b', '/slow/30/c'];
  const bodies = await fetchAll(urls, { fetchFn: fn });
  expect(bodies.map((b) => b.url)).toEqual(urls);
  expect(stats.maxInFlight).toBe(3);
});

test('fetchAll fails fast when one request fails', async () => {
  const { fn } = fakeFetch();
  const started = Date.now();
  await expect(fetchAll(['/slow/1500', '/status/500'], { fetchFn: fn })).rejects.toThrow(/500/);
  expect(Date.now() - started).toBeLessThan(1000);
});

/* HINT
Build the signal list: `[AbortSignal.timeout(timeoutMs)]`, plus `signal` if
given, then `fetchFn(url, { signal: AbortSignal.any(list) })`.
Check `res.ok`; when it is false, throw an Error that mentions `res.status`.
fetchAll: `Promise.all(urls.map((url) => fetchJson(url, options)))`.
*/

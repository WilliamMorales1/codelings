// node8.js
//
// Concurrency and cancellation: Promise.all, AbortSignal
//
// `await` inside a `for` loop runs requests one after another. To run them
// at the same time, start them all and wait for the lot with `Promise.all`,
// which also rejects as soon as any one of them fails.
//
// Cancellation in modern JS is an `AbortSignal`: pass `{ signal }` to fetch
// and it rejects when the signal aborts. `AbortSignal.timeout(ms)` aborts by
// itself after `ms` (with a 'TimeoutError'), and `AbortSignal.any([a, b])`
// aborts when either input does.
//
// Task:
//   - fetchJson(url, { timeoutMs, signal, fetchFn }) calls fetchFn(url, { signal })
//     with a signal that aborts after timeoutMs *or* when the caller's
//     optional `signal` aborts, throws on a non-2xx response (message must
//     include the status), and returns the parsed JSON body.
//   - fetchAll(urls, options) fetches every URL concurrently and resolves to
//     the bodies in the same order as `urls`.
// fetchFn defaults to the global fetch; the tests pass a fake one.

export async function fetchJson(url, { timeoutMs = 5000, signal, fetchFn = fetch } = {}) {
  const res = await fetchFn(url);
  return res.json();
}

export async function fetchAll(urls, options = {}) {
  const results = [];
  for (const url of urls) {
    results.push(await fetchJson(url, options));
  }
  return results;
}

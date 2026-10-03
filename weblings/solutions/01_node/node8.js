// node8.js -- reference solution.

export async function fetchJson(url, { timeoutMs = 5000, signal, fetchFn = fetch } = {}) {
  const signals = [AbortSignal.timeout(timeoutMs)];
  if (signal) signals.push(signal);
  const res = await fetchFn(url, { signal: AbortSignal.any(signals) });
  if (!res.ok) throw new Error(`${url}: HTTP ${res.status}`);
  return res.json();
}

export function fetchAll(urls, options = {}) {
  return Promise.all(urls.map((url) => fetchJson(url, options)));
}

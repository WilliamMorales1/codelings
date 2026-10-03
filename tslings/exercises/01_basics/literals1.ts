// literals1 — Literal types
//
// A string literal type like 'GET' allows exactly one value. A union of them
// is the TypeScript way to spell "one of these strings", and the compiler
// then catches typos like 'get' or 'PATCH'.
//
// Task:
//   1. Narrow `Method` from `string` to 'GET' | 'POST' | 'PUT' | 'DELETE'.
//   2. That breaks `retryRequest`: `defaults` is inferred as { method: string }
//      because object properties are mutable. Fix it without casting to Method.
//

export type Method = string;

export function send(method: Method, url: string): string {
  return `${method} ${url}`;
}

const defaults = { method: 'GET', url: '/health' };

export function retryRequest(): string {
  return send(defaults.method, defaults.url);
}

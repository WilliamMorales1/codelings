import { expect, expectTypeOf, it } from 'vitest';
import { retryRequest, send, type Method } from '@ex/01_basics/literals1.ts';

it('sends requests', () => {
  expect(send('POST', '/users')).toBe('POST /users');
  expect(retryRequest()).toBe('GET /health');
});

it('Method is a union of four literals', () => {
  expectTypeOf<Method>().toEqualTypeOf<'GET' | 'POST' | 'PUT' | 'DELETE'>();
});

it('rejects typos', () => {
  // @ts-expect-error lowercase is not a Method
  send('get', '/users');
  // @ts-expect-error PATCH is not in the list
  send('PATCH', '/users');
});

/* HINT
`as const` after an object literal makes every property readonly and keeps
literal types: { readonly method: 'GET'; readonly url: '/health' }.
Alternatively annotate: `const defaults: { method: Method; url: string } = ...`.
*/

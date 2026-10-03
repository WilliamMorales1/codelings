import { describe, expect, expectTypeOf, it } from 'vitest';
import { fetchUser, parseUser } from '@ex/08_real_world/fetch1.ts';

const fakeFetch = (body: unknown, status = 200): typeof fetch =>
  async () => new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } });

describe('parseUser', () => {
  it('accepts a user and drops unknown fields', () => {
    expect(parseUser({ id: 1, name: 'Ada', email: 'a@x', extra: true })).toEqual({ id: 1, name: 'Ada', email: 'a@x' });
  });

  it('rejects bad data, naming the field', () => {
    expect(() => parseUser(null)).toThrow();
    expect(() => parseUser([])).toThrow();
    expect(() => parseUser({ id: '1', name: 'Ada', email: 'a@x' })).toThrow(/id/);
    expect(() => parseUser({ id: 1, name: 'Ada' })).toThrow(/email/);
  });

  it('takes unknown, not any', () => {
    expectTypeOf(parseUser).parameter(0).toEqualTypeOf<unknown>();
  });
});

describe('fetchUser', () => {
  it('returns a parsed user', async () => {
    await expect(fetchUser(1, fakeFetch({ id: 1, name: 'Ada', email: 'a@x' }))).resolves.toEqual({
      id: 1,
      name: 'Ada',
      email: 'a@x',
    });
  });

  it('fails on HTTP errors', async () => {
    await expect(fetchUser(1, fakeFetch({ error: 'nope' }, 404))).rejects.toThrow('HTTP 404');
  });

  it('fails on the wrong shape', async () => {
    await expect(fetchUser(1, fakeFetch({ id: 1, username: 'ada' }))).rejects.toThrow(/name/);
  });
});

/* HINT
Start parseUser with a guard for "is a non-null, non-array object":
  if (typeof data !== 'object' || data === null || Array.isArray(data)) throw ...
then check each field, e.g. `if (!('id' in data) || typeof data.id !== 'number')`.
Build and return a fresh `{ id, name, email }` so extra fields don't leak.
In fetchUser: `if (!res.ok) throw new Error(`HTTP ${res.status}`)`, then
`const body: unknown = await res.json(); return parseUser(body);`
*/

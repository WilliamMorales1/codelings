import { expect, expectTypeOf, it } from 'vitest';
import { err, map, ok, parseAge, type AgeError, type Result } from '@ex/08_real_world/result1.ts';

it('parses ages without throwing', () => {
  expect(parseAge('42')).toEqual({ ok: true, value: 42 });
  expect(parseAge('')).toEqual({ ok: false, error: 'empty' });
  expect(parseAge('4.5')).toEqual({ ok: false, error: 'not-a-number' });
  expect(parseAge('abc')).toEqual({ ok: false, error: 'not-a-number' });
  expect(parseAge('200')).toEqual({ ok: false, error: 'out-of-range' });
});

it('maps', () => {
  expect(map(ok(2), (n) => n * 10)).toEqual({ ok: true, value: 20 });
  const failed: Result<number, string> = err('boom');
  expect(map(failed, (n) => n * 10)).toEqual({ ok: false, error: 'boom' });
});

it('makes failure visible in the types', () => {
  expectTypeOf(parseAge).returns.toEqualTypeOf<Result<number, AgeError>>();
  expectTypeOf<Result<number, string>>().toEqualTypeOf<{ ok: true; value: number } | { ok: false; error: string }>();
  const r = parseAge('7');
  // @ts-expect-error must check r.ok first
  r.value;
  if (r.ok) expectTypeOf(r.value).toEqualTypeOf<number>();
  else expectTypeOf(r.error).toEqualTypeOf<AgeError>();
});

/* HINT
The type is in the header. ok(v) returns `{ ok: true, value: v }`.
In parseAge, replace each `throw new Error('x')` with `return err('x')`
and the final return with `return ok(n)`.
map: `return r.ok ? ok(f(r.value)) : r;` — in the else branch r is the error
member, which is a valid Result<U, E> whatever U is.
*/

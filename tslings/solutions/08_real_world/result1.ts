// result1 — A Result type instead of exceptions
//
// A thrown error is invisible in a function's type: `parseAge(s): number`
// doesn't tell callers it can fail, and `catch (e)` hands them `unknown`.
// A Result makes failure part of the return type, as a discriminated union:
//
//   type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };
//
// Callers must check `.ok` before they can touch `.value`.
//
// Task:
//   - define Result<T, E> and the helpers ok() and err()
//   - make parseAge return Result<number, AgeError> instead of throwing
//     ('empty' for '', 'not-a-number', 'out-of-range' outside 0..150)
//   - implement map(): transform the value of an ok result, pass errors through

export type AgeError = 'empty' | 'not-a-number' | 'out-of-range';

export type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };

export function ok<T>(value: T): Result<T, never> {
  return { ok: true, value };
}

export function err<E>(error: E): Result<never, E> {
  return { ok: false, error };
}

export function parseAge(input: string): Result<number, AgeError> {
  if (input.trim() === '') return err('empty');
  const n = Number(input);
  if (!Number.isInteger(n)) return err('not-a-number');
  if (n < 0 || n > 150) return err('out-of-range');
  return ok(n);
}

export function map<T, U, E>(r: Result<T, E>, f: (value: T) => U): Result<U, E> {
  return r.ok ? ok(f(r.value)) : r;
}

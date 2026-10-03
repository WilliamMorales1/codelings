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
//

export type AgeError = 'empty' | 'not-a-number' | 'out-of-range';

// TODO: a discriminated union on `ok`.
export type Result<T, E> = any;

export function ok<T>(value: T): Result<T, never> {
  throw new Error('TODO');
}

export function err<E>(error: E): Result<never, E> {
  throw new Error('TODO');
}

export function parseAge(input: string): number {
  if (input.trim() === '') throw new Error('empty');
  const n = Number(input);
  if (!Number.isInteger(n)) throw new Error('not-a-number');
  if (n < 0 || n > 150) throw new Error('out-of-range');
  return n;
}

export function map<T, U, E>(r: Result<T, E>, f: (value: T) => U): Result<U, E> {
  throw new Error('TODO');
}

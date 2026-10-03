// readonly1 — Readonly arrays
//
// `readonly string[]` (or `ReadonlyArray<string>`) is an array type without
// push, pop, sort, splice and the other mutating methods. A function that
// only *reads* an array should take a readonly one: it documents the
// promise, and it lets callers pass arrays that are themselves readonly,
// such as the `as const` list below. (A mutable array is fine to pass to a
// readonly parameter; the reverse is not.)
//
// There's also a real bug: Array.prototype.sort sorts *in place*, so
// `sorted` quietly reorders the caller's array.
//
// Task: make `sorted` accept readonly arrays and stop mutating its input.
//

export function sorted(xs: string[]): string[] {
  return xs.sort();
}

export const FRUITS = ['pear', 'apple', 'fig'] as const;

export function alphabetical(): string[] {
  return sorted(FRUITS);
}

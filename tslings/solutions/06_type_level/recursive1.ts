// recursive1 — Recursive types
//
// A type alias may refer to itself. That's how you describe JSON, trees, and
// "deep" versions of the mapped types from mapped1:
//
//   type Json = string | number | boolean | null | Json[] | { [k: string]: Json };
//
// Task:
//   Json             any JSON value (so `() => 1` or `undefined` are rejected)
//   DeepReadonly<T>  readonly all the way down, through nested objects and
//                    arrays; functions are left alone
//   Flatten<T>       [1, [2, [3, [4]]]]  ->  [1, 2, 3, 4]

export type Json = string | number | boolean | null | Json[] | { [key: string]: Json };

export type DeepReadonly<T> = T extends (...args: never[]) => unknown
  ? T
  : T extends object
    ? { readonly [K in keyof T]: DeepReadonly<T[K]> }
    : T;

export type Flatten<T extends readonly unknown[]> = T extends readonly [infer H, ...infer Rest]
  ? H extends readonly unknown[]
    ? [...Flatten<H>, ...Flatten<Rest>]
    : [H, ...Flatten<Rest>]
  : [];

export function freezeDeep<T>(value: T): DeepReadonly<T> {
  if (typeof value === 'object' && value !== null) {
    for (const v of Object.values(value)) freezeDeep(v);
    Object.freeze(value);
  }
  return value as DeepReadonly<T>;
}

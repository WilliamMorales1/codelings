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
//

export type Json = any;

export type DeepReadonly<T> = any;

export type Flatten<T extends readonly unknown[]> = any;

export function freezeDeep<T>(value: T): DeepReadonly<T> {
  if (typeof value === 'object' && value !== null) {
    for (const v of Object.values(value)) freezeDeep(v);
    Object.freeze(value);
  }
  return value as DeepReadonly<T>;
}

// challenge1 — Typed dotted paths (medium)
//
// Libraries like lodash.get, react-hook-form and i18next accept paths such
// as 'server.port'. Typed well, a typo in a path is a compile error and the
// return type is the type found at that path.
//
// Put the chapter together:
//   Paths<T>       every dotted path to a leaf (non-object) value in T
//                  { a: { b: number; c: string }; d: boolean }  ->  'a.b' | 'a.c' | 'd'
//   PathValue<T,P> the type at path P
//   get(obj, path) runtime version, typed with the two above
//
// Arrays can be treated as leaves.

type Leaf = string | number | boolean | bigint | symbol | null | undefined | readonly unknown[] | ((...args: never[]) => unknown);

export type Paths<T> = T extends Leaf
  ? never
  : { [K in keyof T & string]: T[K] extends Leaf ? K : `${K}.${Paths<T[K]>}` }[keyof T & string];

export type PathValue<T, P extends string> = P extends `${infer Head}.${infer Rest}`
  ? Head extends keyof T
    ? PathValue<T[Head], Rest>
    : never
  : P extends keyof T
    ? T[P]
    : never;

export function get<T, P extends Paths<T>>(obj: T, path: P): PathValue<T, P> {
  let cur: unknown = obj;
  for (const key of path.split('.')) cur = (cur as Record<string, unknown>)[key];
  return cur as PathValue<T, P>;
}

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
//

export type Paths<T> = any;

export type PathValue<T, P extends string> = any;

export function get<T, P extends Paths<T>>(obj: T, path: P): PathValue<T, P> {
  let cur: unknown = obj;
  for (const key of path.split('.')) cur = (cur as Record<string, unknown>)[key];
  return cur as PathValue<T, P>;
}

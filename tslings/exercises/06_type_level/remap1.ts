// remap1 — Key remapping with `as`
//
// A mapped type can rename keys, or drop them by mapping to `never`:
//
//   { [K in keyof T as `get${Capitalize<K & string>}`]: () => T[K] }
//   { [K in keyof T as T[K] extends string ? K : never]: T[K] }
//
// (`K & string` because keyof can also contain number and symbol keys, and
// Capitalize only takes strings.)
//
// Task:
//   Getters<T>        { name: string }  ->  { getName: () => string }
//   PickByType<T, V>  keep only properties whose type is assignable to V
//   and implement `makeGetters` so it returns what Getters promises.
//

export type Getters<T> = any;

export type PickByType<T, V> = any;

export function makeGetters<T extends object>(obj: T): Getters<T> {
  // TODO: build { getName: () => obj.name, ... } for every key of obj
  return {};
}

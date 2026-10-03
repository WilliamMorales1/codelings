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

export type Getters<T> = {
  [K in keyof T as `get${Capitalize<K & string>}`]: () => T[K];
};

export type PickByType<T, V> = {
  [K in keyof T as T[K] extends V ? K : never]: T[K];
};

export function makeGetters<T extends object>(obj: T): Getters<T> {
  const out: Record<string, () => unknown> = {};
  for (const [key, value] of Object.entries(obj)) {
    out[`get${key.charAt(0).toUpperCase()}${key.slice(1)}`] = () => value;
  }
  // Object.entries loses the key/value pairing, so the result has to be asserted.
  return out as Getters<T>;
}

// nonnullable1 — NonNullable
//
// `NonNullable<T>` removes null and undefined from T:
//   NonNullable<string | null | undefined>   is   string
//
// `compact` is supposed to drop null and undefined from a list, and its
// return type should say so — callers shouldn't have to check again. Right
// now it only removes null, and its return type promises nothing.
//
// Task: fix the filter and the return type. Since TypeScript 5.5 a callback
// like `(x) => x != null` is inferred as a type predicate, so `.filter`
// narrows by itself when the check is right.
//

export function compact<T>(xs: readonly T[]): T[] {
  return xs.filter((x) => x !== null);
}

// guards1 — User-defined type guards
//
// A function returning `value is User` is a *type predicate*: when it returns
// true, callers (and `.filter`) narrow the argument to User. A function that
// merely returns `boolean` tells the compiler nothing.
//
// The predicate is a promise you make — TypeScript does not check that your
// body actually verifies the claim. A sloppy guard is worse than none.
//
// Task: make `isUser` a real type predicate, and make its body check that
// `id` is a number and `name` is a string, not just that they exist.

export interface User {
  id: number;
  name: string;
}

export function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    typeof value.id === 'number' &&
    'name' in value &&
    typeof value.name === 'string'
  );
}

export function userNames(values: unknown[]): string[] {
  return values.filter(isUser).map((u) => u.name);
}

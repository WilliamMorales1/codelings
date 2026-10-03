// generics1 — Generic constraints
//
// A type parameter `<T>` means "any type at all", so inside the function you
// can do nothing with a T that some type might not support — not even read
// `.length`. A constraint narrows what T may be:
//
//   function f<T extends { length: number }>(x: T)   // x.length is fine
//
// `keyof T` is the union of T's property names; `K extends keyof T` ties a
// second type parameter to the first, and `T[K]` is the type of that property.
//
// Task:
//   - `longest` returns whichever argument is longer (strings or arrays).
//   - `pluck` returns the given property of each item, and must reject keys
//     that items don't have. `pluck(users, 'age')` is `number[]`.

export function longest<T extends { length: number }>(a: T, b: T): T {
  return a.length >= b.length ? a : b;
}

export function pluck<T, K extends keyof T>(items: T[], key: K): T[K][] {
  return items.map((item) => item[key]);
}

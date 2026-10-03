// generics3 — Inference from arguments, and `const` type parameters
//
// You rarely write `first<number>(xs)`: TypeScript infers type arguments from
// the values you pass. That only helps if the function is generic — `any`
// in, `any` out throws the information away.
//
// For literals, inference picks the widened type: a route object's '/' is
// inferred as `string`. Adding `const` before a type parameter asks for the
// narrowest type instead, as if the caller had written `as const`:
//
//   function f<const T>(x: T): T
//
// Task:
//   - make `first` generic so `first([1, 2])` is `number | undefined`.
//   - make `defineRoutes` keep each path as its literal type, so that
//     `routes.user` is '/users/:id', not string. Callers must not need
//     `as const`.

export function first<T>(xs: readonly T[]): T | undefined {
  return xs[0];
}

export function defineRoutes<const T extends Record<string, string>>(routes: T): T {
  return routes;
}

export const routes = defineRoutes({ home: '/', user: '/users/:id' });

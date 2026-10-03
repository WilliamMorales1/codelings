// template2 — Parsing strings with `infer`
//
// Template literal types can also be *matched*, with infer in the holes:
//
//   'user:42' extends `${infer Kind}:${infer Id}` ? [Kind, Id] : never
//   // ['user', '42']
//
// Combined with recursion, that's enough to parse route patterns at the type
// level — which is what typed routers (Hono, tRPC, TanStack Router) do so
// that `params.id` is an error when the route has no `:id`.
//
// Task:
//   RouteParams<'/users/:id/posts/:postId'>  ->  'id' | 'postId'
//   RouteParams<'/about'>                    ->  never
//   Params<R>                                an object with a string per param
//

export type RouteParams<R extends string> = any;

export type Params<R extends string> = any;

export function fillRoute<R extends string>(route: R, params: Params<R>): string {
  return route.replace(/:(\w+)/g, (_, name: string) => (params as Record<string, string>)[name] ?? '');
}

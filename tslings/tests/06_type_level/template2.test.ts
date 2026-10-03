import { expect, expectTypeOf, it } from 'vitest';
import { fillRoute, type Params, type RouteParams } from '@ex/06_type_level/template2.ts';

it('RouteParams', () => {
  expectTypeOf<RouteParams<'/users/:id'>>().toEqualTypeOf<'id'>();
  expectTypeOf<RouteParams<'/users/:id/posts/:postId'>>().toEqualTypeOf<'id' | 'postId'>();
  expectTypeOf<RouteParams<'/orgs/:org/repos/:repo/issues/:n'>>().toEqualTypeOf<'org' | 'repo' | 'n'>();
  expectTypeOf<RouteParams<'/about'>>().toEqualTypeOf<never>();
});

it('Params', () => {
  expectTypeOf<Params<'/users/:id'>>().toEqualTypeOf<{ id: string }>();
});

it('fillRoute', () => {
  expect(fillRoute('/users/:id/posts/:postId', { id: '7', postId: '42' })).toBe('/users/7/posts/42');
  // @ts-expect-error missing postId
  fillRoute('/users/:id/posts/:postId', { id: '7' });
  // @ts-expect-error no such param
  fillRoute('/users/:id', { id: '7', slug: 'x' });
});

/* HINT
Two cases: a param followed by more path, or a param at the very end.
  R extends `${string}:${infer Param}/${infer Rest}`
    ? Param | RouteParams<`/${Rest}`>
    : R extends `${string}:${infer Param}` ? Param : never
`${string}` matches (and discards) everything before the colon. Then
  Params<R> = { [K in RouteParams<R>]: string }
*/

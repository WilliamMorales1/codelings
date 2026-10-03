import { expect, expectTypeOf, it } from 'vitest';
import { defineRoutes, first, routes } from '@ex/04_functions/generics3.ts';

it('first infers the element type', () => {
  expect(first([1, 2])).toBe(1);
  expect(first([])).toBeUndefined();
  expectTypeOf(first([1, 2])).toEqualTypeOf<number | undefined>();
  expectTypeOf(first(['a'])).toEqualTypeOf<string | undefined>();
});

it('routes keep their literal paths', () => {
  expect(routes.user).toBe('/users/:id');
  expectTypeOf(routes.user).toEqualTypeOf<'/users/:id'>();
  expectTypeOf(defineRoutes({ a: '/a' }).a).toEqualTypeOf<'/a'>();
});

/* HINT
  function first<T>(xs: readonly T[]): T | undefined   // xs[0] may not exist
  function defineRoutes<const T extends Record<string, string>>(routes: T): T
*/

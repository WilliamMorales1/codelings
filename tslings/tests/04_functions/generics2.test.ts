import { expect, expectTypeOf, it } from 'vitest';
import { firstPage, logStatus, type ApiResponse, type Page } from '@ex/04_functions/generics2.ts';

it('works at runtime', () => {
  expect(logStatus({ status: 404, data: null })).toBe('HTTP 404');
  expect(firstPage().next).toBe('cursor-2');
});

it('has the right defaults', () => {
  expectTypeOf<ApiResponse['data']>().toEqualTypeOf<unknown>();
  expectTypeOf<Page<number>['next']>().toEqualTypeOf<string | null>();
  expectTypeOf<Page<number, number>['next']>().toEqualTypeOf<number | null>();
});

/* HINT
  interface ApiResponse<T = unknown> { ... }
  interface Page<Item, Cursor = string> { ... }
Like function parameters, type parameters with defaults must come after
the ones without.
*/

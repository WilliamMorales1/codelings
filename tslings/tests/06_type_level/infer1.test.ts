import { expectTypeOf, it } from 'vitest';
import type { FirstArg, Head, MyReturnType, UnwrapPromise } from '@ex/06_type_level/infer1.ts';

it('MyReturnType', () => {
  expectTypeOf<MyReturnType<() => string>>().toEqualTypeOf<string>();
  expectTypeOf<MyReturnType<(a: number, b: boolean) => { ok: true }>>().toEqualTypeOf<{ ok: true }>();
});

it('FirstArg', () => {
  expectTypeOf<FirstArg<(id: number, name: string) => void>>().toEqualTypeOf<number>();
  expectTypeOf<FirstArg<() => void>>().toEqualTypeOf<never>();
});

it('UnwrapPromise', () => {
  expectTypeOf<UnwrapPromise<Promise<string[]>>>().toEqualTypeOf<string[]>();
  expectTypeOf<UnwrapPromise<number>>().toEqualTypeOf<number>();
});

it('Head', () => {
  expectTypeOf<Head<[1, 2, 3]>>().toEqualTypeOf<1>();
  expectTypeOf<Head<readonly ['a']>>().toEqualTypeOf<'a'>();
  expectTypeOf<Head<[]>>().toEqualTypeOf<never>();
});

/* HINT
Put `infer X` where the part you want sits in the pattern:
  F extends (...args: never[]) => infer R ? R : never
  F extends (...args: infer P) => unknown ? (P extends [infer A, ...unknown[]] ? A : never) : never
  T extends Promise<infer V> ? V : T
  T extends readonly [infer H, ...unknown[]] ? H : never
(`never[]` for parameters accepts functions with any parameter types;
`any[]` also works but is less strict. FirstArg goes via the whole
parameter tuple so that a function with no parameters gives never.)
*/

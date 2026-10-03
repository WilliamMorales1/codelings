import { expectTypeOf, it } from 'vitest';
import type { If, IsString, MyExclude, MyExtract } from '@ex/06_type_level/conditional1.ts';

it('If', () => {
  expectTypeOf<If<true, 'a', 'b'>>().toEqualTypeOf<'a'>();
  expectTypeOf<If<false, 'a', 2>>().toEqualTypeOf<2>();
});

it('IsString', () => {
  expectTypeOf<IsString<'hello'>>().toEqualTypeOf<true>();
  expectTypeOf<IsString<string>>().toEqualTypeOf<true>();
  expectTypeOf<IsString<42>>().toEqualTypeOf<false>();
});

it('MyExclude / MyExtract', () => {
  expectTypeOf<MyExclude<'a' | 'b' | 'c', 'a'>>().toEqualTypeOf<'b' | 'c'>();
  expectTypeOf<MyExclude<string | number | (() => void), Function>>().toEqualTypeOf<string | number>();
  expectTypeOf<MyExtract<'a' | 'b' | 1 | 2, string>>().toEqualTypeOf<'a' | 'b'>();
});

/* HINT
Each one is a single conditional:
  If:        C extends true ? T : F
  MyExclude: T extends U ? never : T     (never vanishes from a union)
  MyExtract: the same with the branches swapped.
*/

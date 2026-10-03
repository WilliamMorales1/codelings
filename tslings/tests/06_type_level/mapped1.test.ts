import { expectTypeOf, it } from 'vitest';
import type { Mutable, MyPartial, MyReadonly, MyRequired } from '@ex/06_type_level/mapped1.ts';

interface Todo {
  title: string;
  done: boolean;
}

it('MyReadonly / MyPartial', () => {
  expectTypeOf<MyReadonly<Todo>>().toEqualTypeOf<{ readonly title: string; readonly done: boolean }>();
  expectTypeOf<MyPartial<Todo>>().toEqualTypeOf<{ title?: string; done?: boolean }>();
});

it('Mutable / MyRequired', () => {
  expectTypeOf<Mutable<{ readonly a: 1; readonly b: 'x' }>>().toEqualTypeOf<{ a: 1; b: 'x' }>();
  expectTypeOf<MyRequired<{ a?: number; b: string }>>().toEqualTypeOf<{ a: number; b: string }>();
});

/* HINT
All four have the shape `{ [K in keyof T]: T[K] }` with a modifier:
`readonly` in front, `?` after `]`, or `-readonly` / `-?` to remove one.
*/

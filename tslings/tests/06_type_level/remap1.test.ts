import { expect, expectTypeOf, it } from 'vitest';
import { makeGetters, type Getters, type PickByType } from '@ex/06_type_level/remap1.ts';

interface Person {
  name: string;
  age: number;
  email: string;
}

it('Getters', () => {
  expectTypeOf<Getters<Person>>().toEqualTypeOf<{
    getName: () => string;
    getAge: () => number;
    getEmail: () => string;
  }>();
});

it('PickByType', () => {
  expectTypeOf<PickByType<Person, string>>().toEqualTypeOf<{ name: string; email: string }>();
  expectTypeOf<PickByType<Person, number>>().toEqualTypeOf<{ age: number }>();
});

it('makeGetters', () => {
  const g = makeGetters({ name: 'Ada', age: 36 });
  expect(g.getName()).toBe('Ada');
  expect(g.getAge()).toBe(36);
  expectTypeOf(g.getAge).returns.toEqualTypeOf<number>();
});

/* HINT
The header shows both mapped types almost verbatim. For makeGetters, loop
over Object.entries(obj), build the getter names at runtime with
`'get' + key[0].toUpperCase() + key.slice(1)` into a Record<string, ...>,
and return it with `as Getters<T>`: the runtime loop can't prove the
mapped type to the compiler, so this is one of the places a cast is honest.
*/

import { expect, expectTypeOf, it } from 'vitest';
import { array, boolean, number, object, string, type Infer } from '@ex/08_real_world/validate1.ts';

const User = object({
  name: string(),
  age: number(),
  admin: boolean(),
  tags: array(string()),
  address: object({ city: string() }),
});
type User = Infer<typeof User>;

it('infers the type from the schema', () => {
  expectTypeOf<User>().toEqualTypeOf<{
    name: string;
    age: number;
    admin: boolean;
    tags: string[];
    address: { city: string };
  }>();
  expectTypeOf<Infer<ReturnType<typeof string>>>().toEqualTypeOf<string>();
});

it('parses good input and drops unknown keys', () => {
  const input = { name: 'Ada', age: 36, admin: false, tags: ['math'], address: { city: 'London' }, extra: 1 };
  const user: User = User.parse(input);
  expect(user).toEqual({ name: 'Ada', age: 36, admin: false, tags: ['math'], address: { city: 'London' } });
});

it('reports the path of bad input', () => {
  const good = { name: 'Ada', age: 36, admin: false, tags: [], address: { city: 'London' } };
  expect(() => User.parse(null)).toThrow('(root): expected object');
  expect(() => User.parse({ ...good, age: '36' })).toThrow('age: expected number');
  expect(() => User.parse({ ...good, tags: ['a', 2] })).toThrow('tags.1: expected string');
  expect(() => User.parse({ ...good, address: {} })).toThrow('address.city: expected string');
});

/* HINT
  type Infer<S> = S extends Schema<infer T> ? T : never;
  function object<Shape extends Record<string, Schema<unknown>>>(shape: Shape):
    Schema<{ [K in keyof Shape]: Infer<Shape[K]> }>
In parse: reject non-objects (and null, and arrays) with fail(path, 'object');
loop over Object.entries(shape), parsing input[key] with the child path
`path ? `${path}.${key}` : key`, into a fresh object; return it with one
`as` — like array(), but the compiler can't follow the per-key types.
*/

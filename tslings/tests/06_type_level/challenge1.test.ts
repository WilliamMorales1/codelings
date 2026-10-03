import { expect, expectTypeOf, it } from 'vitest';
import { get, type PathValue, type Paths } from '@ex/06_type_level/challenge1.ts';

const config = {
  server: { host: 'localhost', port: 8080, tls: { enabled: false } },
  users: ['ada', 'grace'],
  debug: true,
};
type Config = typeof config;

it('Paths', () => {
  expectTypeOf<Paths<{ a: { b: number; c: string }; d: boolean }>>().toEqualTypeOf<'a.b' | 'a.c' | 'd'>();
  expectTypeOf<Paths<Config>>().toEqualTypeOf<
    'server.host' | 'server.port' | 'server.tls.enabled' | 'users' | 'debug'
  >();
});

it('PathValue', () => {
  expectTypeOf<PathValue<Config, 'server.port'>>().toEqualTypeOf<number>();
  expectTypeOf<PathValue<Config, 'server.tls.enabled'>>().toEqualTypeOf<boolean>();
  expectTypeOf<PathValue<Config, 'users'>>().toEqualTypeOf<string[]>();
});

it('get', () => {
  expect(get(config, 'server.tls.enabled')).toBe(false);
  expectTypeOf(get(config, 'server.host')).toEqualTypeOf<string>();
  // @ts-expect-error typo in the path
  get(config, 'server.prot');
  // @ts-expect-error `server` is an object, not a leaf
  get(config, 'server');
});

/* HINT
Paths: map over the keys and immediately index the result with all keys,
which turns an object of answers into a union of answers:
  { [K in keyof T & string]: T[K] extends Leaf ? K : `${K}.${Paths<T[K]>}` }[keyof T & string]
where Leaf is a union of primitives, arrays and functions (define it
yourself), and Paths<Leaf> is never.
PathValue: split off the first segment with `${infer Head}.${infer Rest}`,
recurse into T[Head]; with no dot left, it's T[P].
*/

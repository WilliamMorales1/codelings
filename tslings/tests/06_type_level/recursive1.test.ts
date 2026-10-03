import { expect, expectTypeOf, it } from 'vitest';
import { freezeDeep, type DeepReadonly, type Flatten, type Json } from '@ex/06_type_level/recursive1.ts';

it('Json', () => {
  const ok: Json = { a: [1, 'two', { three: null, four: true }] };
  expect(ok).toBeDefined();
  // @ts-expect-error functions are not JSON
  const f: Json = { a: () => 1 };
  // @ts-expect-error undefined is not JSON
  const u: Json = [undefined];
  expect([f, u]).toHaveLength(2);
});

it('DeepReadonly', () => {
  type Config = { server: { port: number; hosts: string[] }; onError: (e: Error) => void };
  expectTypeOf<DeepReadonly<Config>>().toEqualTypeOf<{
    readonly server: { readonly port: number; readonly hosts: readonly string[] };
    readonly onError: (e: Error) => void;
  }>();
  const c = freezeDeep({ server: { port: 80, hosts: ['a'] } });
  const mutate = () => {
    // @ts-expect-error nested properties are readonly too
    c.server.port = 8080;
  };
  expect(mutate).toThrow(TypeError);
  expect(Object.isFrozen(c.server)).toBe(true);
});

it('Flatten', () => {
  expectTypeOf<Flatten<[1, [2, [3, [4]]]]>>().toEqualTypeOf<[1, 2, 3, 4]>();
  expectTypeOf<Flatten<[]>>().toEqualTypeOf<[]>();
  expectTypeOf<Flatten<[['a'], 'b', [['c']]]>>().toEqualTypeOf<['a', 'b', 'c']>();
});

/* HINT
DeepReadonly: check for functions first (they are objects too), then
  T extends object ? { readonly [K in keyof T]: DeepReadonly<T[K]> } : T
A mapped type over an array type produces a (readonly) array, so arrays
need no special case.
Flatten: peel off the head with `T extends readonly [infer H, ...infer Rest]`;
if H is itself an array, spread `...Flatten<H>`, else keep `H`; then
`...Flatten<Rest>`. The base case is [].
*/

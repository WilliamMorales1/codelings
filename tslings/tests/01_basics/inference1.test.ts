import { expect, expectTypeOf, it } from 'vitest';
import { attempts, config, describeConfig, direction } from '@ex/01_basics/inference1.ts';

it('reads the config', () => {
  expect(describeConfig()).toBe('retries=3 verbose=false');
  expect(attempts).toBe(1);
});

it('keeps the precise inferred types', () => {
  expectTypeOf(config).toEqualTypeOf<{ retries: number; verbose: boolean }>();
  expectTypeOf<typeof direction>().toEqualTypeOf<'north'>();
  expectTypeOf(attempts).toEqualTypeOf<number>();
});

/* HINT
Hover over each name in your editor to see what TypeScript inferred.
Remove the `: object` and `: string` annotations entirely. `attempts` only
ever holds numbers, so `number | string` is a lie that also stops `+= 1`
from being a number operation — let `let attempts = 0` infer it.
*/

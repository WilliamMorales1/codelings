import { expect, expectTypeOf, it } from 'vitest';
import { slugify, version, type SlugifyOptions } from '@ex/07_classes_modules/dts1/slugify.js';

it('slugifies', () => {
  expect(slugify('Hello, World!')).toBe('hello-world');
  expect(slugify('Crème Brûlée', { separator: '_', lower: false })).toBe('Creme_Brulee');
  expect(slugify('a b c d', { maxLength: 3 })).toBe('a-b');
  expect(version).toBe('1.2.0');
});

it('is fully typed', () => {
  expectTypeOf(slugify).toEqualTypeOf<(text: string, options?: SlugifyOptions) => string>();
  expectTypeOf<SlugifyOptions>().toEqualTypeOf<{ separator?: string; lower?: boolean; maxLength?: number }>();
  expectTypeOf(version).toEqualTypeOf<string>();
  const misuse = () => {
    // @ts-expect-error text must be a string
    slugify(42);
    // @ts-expect-error unknown option
    slugify('x', { upper: true });
  };
  expect(misuse).toThrow();
});

/* HINT
  export interface SlugifyOptions {
    separator?: string;
    lower?: boolean;
    maxLength?: number;
  }
  export declare function slugify(text: string, options?: SlugifyOptions): string;
  export declare const version: string;
In a .d.ts file, `declare` is implied for exported functions, but writing
it keeps the intent obvious.
*/

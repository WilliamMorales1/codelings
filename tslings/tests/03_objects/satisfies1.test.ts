import { expect, expectTypeOf, it } from 'vitest';
import { greenHex, palette, redChannel } from '@ex/03_objects/satisfies1.ts';
import { exerciseSource } from '../helpers.ts';

it('reads the palette', () => {
  expect(greenHex).toBe('#00FF00');
  expect(redChannel).toBe(255);
});

it('keeps each entry precise', () => {
  expectTypeOf(palette.green).toEqualTypeOf<string>();
  expectTypeOf(palette.red).toEqualTypeOf<[number, number, number]>();
  expectTypeOf(redChannel).toEqualTypeOf<number>();
});

it('is still checked against the record type', () => {
  expect(exerciseSource('03_objects/satisfies1.ts')).toMatch(/satisfies\s+Record<ColorName,\s*Color>/);
});

/* HINT
Move the type from the left of `=` to the end of the literal:
  export const palette = { ... } satisfies Record<ColorName, Color>;
Because RGB is a tuple type in the target, TypeScript infers the arrays as
tuples, so `palette.red[0]` is a number, not `number | undefined`.
*/

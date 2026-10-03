// satisfies1 — The `satisfies` operator
//
// An annotation `const x: T = ...` checks the value against T and then
// *forgets* the value's own type: x is just T from then on. `satisfies T`
// checks the same thing but keeps the precise inferred type.
//
// Here the annotation makes every colour `string | RGB`, so even `green`,
// which is plainly a string, can't be upper-cased without a check.
//
// Task: keep the palette checked against `Record<ColorName, Color>` (so a
// missing or misspelled colour is still an error) but let each entry keep
// its own type.

export type RGB = [red: number, green: number, blue: number];
export type Color = string | RGB;
export type ColorName = 'red' | 'green' | 'blue';

export const palette = {
  red: [255, 0, 0],
  green: '#00ff00',
  blue: [0, 0, 255],
} satisfies Record<ColorName, Color>;

export const greenHex = palette.green.toUpperCase();
export const redChannel = palette.red[0];

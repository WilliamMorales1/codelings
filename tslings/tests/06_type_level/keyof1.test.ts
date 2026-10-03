import { expect, expectTypeOf, it } from 'vitest';
import { color, space, theme, type ColorName, type Spacing, type Theme } from '@ex/06_type_level/keyof1.ts';

it('works at runtime', () => {
  expect(color('danger')).toBe('#e33e33');
  expect(space(8)).toBe('8px');
});

it('derives types from the theme', () => {
  expectTypeOf<Theme>().toEqualTypeOf<typeof theme>();
  expectTypeOf<ColorName>().toEqualTypeOf<'primary' | 'danger' | 'muted'>();
  expectTypeOf<Spacing>().toEqualTypeOf<0 | 4 | 8 | 16>();
  // @ts-expect-error not a colour
  color('warning');
  // @ts-expect-error not on the spacing scale
  space(5);
});

/* HINT
  export type Theme = typeof theme;
  export type ColorName = keyof Theme['colors'];
  export type Spacing = Theme['spacing'][number];
Indexing a tuple type with `number` gives the union of its element types.
*/

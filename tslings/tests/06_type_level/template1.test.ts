import { expect, expectTypeOf, it } from 'vitest';
import { cssVar, type ClassName, type CssVar, type EventHandlerName } from '@ex/06_type_level/template1.ts';

it('EventHandlerName', () => {
  expectTypeOf<EventHandlerName<'click'>>().toEqualTypeOf<'onClick'>();
  expectTypeOf<EventHandlerName<'click' | 'focus'>>().toEqualTypeOf<'onClick' | 'onFocus'>();
});

it('CssVar', () => {
  expectTypeOf<CssVar<'primary'>>().toEqualTypeOf<'var(--primary)'>();
  expect(cssVar('gap')).toBe('var(--gap)');
  expectTypeOf(cssVar('gap')).toEqualTypeOf<'var(--gap)'>();
});

it('ClassName', () => {
  expectTypeOf<ClassName>().toEqualTypeOf<
    'btn-primary-sm' | 'btn-primary-md' | 'btn-primary-lg' | 'btn-ghost-sm' | 'btn-ghost-md' | 'btn-ghost-lg'
  >();
});

/* HINT
  EventHandlerName<E> = `on${Capitalize<E>}`
  CssVar<N>           = `var(--${N})`
  ClassName           = `btn-${Variant}-${Size}`   (6 members, all generated)
Once CssVar is right, the `return` in cssVar typechecks with no cast:
TypeScript knows `var(--${name})` has type `var(--${N})`.
*/

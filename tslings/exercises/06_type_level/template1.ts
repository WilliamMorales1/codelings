// template1 — Template literal types
//
// Backtick types build string literal types, and they distribute over
// unions:
//
//   type Size = 'sm' | 'lg';
//   `btn-${Size}`         'btn-sm' | 'btn-lg'
//
// Built-in helpers: Uppercase, Lowercase, Capitalize, Uncapitalize.
//
// Task:
//   EventHandlerName<E>  'click' | 'key-down' -> 'onClick' | 'onKey-down'
//   CssVar<N>            'primary'            -> 'var(--primary)'
//   ClassName            every combination of Variant and Size, e.g. 'btn-primary-sm'
//

export type Variant = 'primary' | 'ghost';
export type Size = 'sm' | 'md' | 'lg';

export type EventHandlerName<E extends string> = any;

export type CssVar<N extends string> = any;

export type ClassName = any;

export function cssVar<N extends string>(name: N): CssVar<N> {
  return `var(--${name})`;
}

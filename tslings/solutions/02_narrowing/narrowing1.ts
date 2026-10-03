// narrowing1 — typeof and friends
//
// With a union, TypeScript only lets you do what every member allows. To use
// one member's methods you check which one you have; after the check the
// variable is *narrowed* to that member inside the branch.
//
//   typeof x === 'string' | 'number' | 'boolean' | 'object' | 'function' ...
//   Array.isArray(x)
//   x === null
//
// Beware: typeof null === 'object'.
//
// Task: make `toLabel` handle every member of its parameter type:
//   string    -> upper-cased             'hi'       -> 'HI'
//   number    -> two decimals            3.14159    -> '3.14'
//   string[]  -> joined with ', '        ['a', 'b'] -> 'a, b'
//   null      -> '(none)'

export function toLabel(value: string | number | string[] | null): string {
  if (value === null) return '(none)';
  if (typeof value === 'string') return value.toUpperCase();
  if (typeof value === 'number') return value.toFixed(2);
  return value.join(', ');
}

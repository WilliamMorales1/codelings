// discriminated1 — Discriminated unions
//
// A common first attempt at "a shape is a circle or a square" is one
// interface with optional fields. It type-checks nonsense like
// { kind: 'circle', size: 2 } and forces `!` or `?? 0` everywhere, because
// TypeScript can't know that circles always have a radius.
//
// A discriminated union is several object types sharing a literal field (the
// *discriminant*). Checking `s.kind === 'circle'` then narrows `s` to the
// circle member, whose `radius` is not optional.
//
// Task: turn Shape into a discriminated union of circle, square and rect
// (rect has width and height), with no optional fields, and fix `area`.
//

export interface Shape {
  kind: 'circle' | 'square' | 'rect';
  radius?: number;
  size?: number;
  width?: number;
  height?: number;
}

export function area(s: Shape): number {
  if (s.kind === 'circle') return Math.PI * s.radius ** 2;
  if (s.kind === 'square') return s.size ** 2;
  return s.width * s.height;
}

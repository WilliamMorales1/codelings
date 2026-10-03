import { expect, it } from 'vitest';
import { area, type Shape } from '@ex/02_narrowing/discriminated1.ts';

it('computes areas', () => {
  expect(area({ kind: 'circle', radius: 1 })).toBeCloseTo(Math.PI);
  expect(area({ kind: 'square', size: 3 })).toBe(9);
  expect(area({ kind: 'rect', width: 2, height: 5 })).toBe(10);
});

it('rejects shapes that make no sense', () => {
  // @ts-expect-error a circle has a radius, not a size
  const a: Shape = { kind: 'circle', size: 2 };
  // @ts-expect-error a rect needs a height
  const b: Shape = { kind: 'rect', width: 2 };
  expect([a, b]).toHaveLength(2);
});

/* HINT
  export type Shape =
    | { kind: 'circle'; radius: number }
    | { kind: 'square'; size: number }
    | { kind: 'rect'; width: number; height: number };
`area` then compiles unchanged: each `if` narrows `s` to one member.
*/

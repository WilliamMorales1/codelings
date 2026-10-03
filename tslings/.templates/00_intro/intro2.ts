// intro2 — Reading a compiler error
//
// Most failures in this course are type errors, not test failures. Run
// `node tslings.ts run intro2` and read the message: it tells you the file,
// line and column, and what TypeScript expected versus what it found.
//
// Task: make `total` add up the prices. Don't touch the type annotations —
// they are the spec. Fix the value that disagrees with them.
//

export const prices: number[] = [3, 4, "5"];

export function total(xs: number[]): number {
  let sum = 0;
  for (const x of xs) sum += x;
  return sum;
}

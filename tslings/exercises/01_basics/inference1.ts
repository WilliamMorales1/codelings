// inference1 — Let inference do the work
//
// An annotation is a promise that a value is *at least* that general. Annotate
// too widely and you throw information away: `object` knows nothing about the
// properties, and `string` has forgotten which string it was.
//
// `const x = 'north'` infers the literal type 'north' (it can never change);
// `let x = 'north'` infers `string` (it might).
//
// Task: delete or fix the annotations so that the rest of the file compiles
// and the inferred types are as precise as the tests expect.
//

export const config: object = { retries: 3, verbose: false };

export function describeConfig(): string {
  return `retries=${config.retries} verbose=${config.verbose}`;
}

export const direction: string = 'north';

export let attempts: number | string = 0;
attempts += 1;

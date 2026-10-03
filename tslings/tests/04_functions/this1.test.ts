import { expect, it } from 'vitest';
import { countClicks, makeCounter } from '@ex/04_functions/this1.ts';

it('counts clicks', () => {
  expect(countClicks(3)).toBe(3);
});

it('refuses to detach increment', () => {
  const c = makeCounter();
  // @ts-expect-error increment needs its Counter as `this`
  const detached: (this: void) => void = c.increment;
  expect(typeof detached).toBe('function');
});

/* HINT
Interface: `increment(this: Counter): void;`
Call site: wrap it so it's still called *on* the counter:
  clickTimes(n, () => counter.increment());
(`counter.increment.bind(counter)` also works.)
*/

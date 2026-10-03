import { expect, it } from 'vitest';
import { countOf, countWords } from '@ex/03_objects/index1.ts';

it('counts words', () => {
  expect(countWords(' the cat and The hat ')).toEqual({ the: 2, cat: 1, and: 1, hat: 1 });
});

it('treats missing words as zero', () => {
  const c = countWords('a b a');
  expect(countOf(c, 'a')).toBe(2);
  expect(countOf(c, 'zebra')).toBe(0);
});

/* HINT
`counts[word] ?? 0` turns `number | undefined` into a number: `??` falls
back only on null/undefined (unlike `||`, which would also replace 0).
Skip empty words with `if (word === '') continue;`.
*/

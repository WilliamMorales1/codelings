import { expect, it } from 'vitest';
import { fullName, greet, sum } from '@ex/04_functions/functions1.ts';

it('greets with a default greeting', () => {
  expect(greet('Ada')).toBe('Hello, Ada!');
  expect(greet('Ada', 'Welcome')).toBe('Welcome, Ada!');
});

it('sums any number of arguments', () => {
  expect(sum(1, 2, 3)).toBe(6);
  expect(sum()).toBe(0);
});

it('has an optional middle name', () => {
  expect(fullName('Ada', 'Lovelace')).toBe('Ada Lovelace');
  expect(fullName('Ada', 'Lovelace', 'King')).toBe('Ada King Lovelace');
});

/* HINT
  greet(name: string, greeting = 'Hello')
  sum(...nums: number[])
  fullName(first: string, last: string, middle?: string)
Watch the runtime too: joining [first, undefined, last] gives 'Ada  Lovelace'
with two spaces. Check `middle === undefined` and build the string accordingly.
*/

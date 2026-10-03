import { expect, test } from 'vitest';
import { greeting } from '@ex/00_intro/intro1.js';

test('greets the course by default', () => {
  expect(greeting()).toBe('Hello, weblings!');
});

test('greets anyone else', () => {
  expect(greeting('rust')).toBe('Hello, rustlings!');
});

/* HINT
greeting() appends "lings" to its argument, so the default name should be
'web', not 'world'.
*/

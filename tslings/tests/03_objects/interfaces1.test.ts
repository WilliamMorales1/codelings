import { expect, expectTypeOf, it } from 'vitest';
import { makePost, type Post } from '@ex/03_objects/interfaces1.ts';
import { exerciseSource } from '../helpers.ts';

it('stamps posts with dates', () => {
  const p = makePost('hello');
  expect(p.title).toBe('hello');
  expect(p.createdAt).toBeInstanceOf(Date);
  expect(p.updatedAt).toBeInstanceOf(Date);
});

it('createdAt is a Date', () => {
  expectTypeOf<Post['createdAt']>().toEqualTypeOf<Date>();
});

it('uses interface extends', () => {
  expect(exerciseSource('03_objects/interfaces1.ts')).toMatch(/interface\s+Post\s+extends\s+Timestamps/);
});

/* HINT
  export interface Post extends Timestamps {
    title: string;
  }
Keeping `createdAt: string` inside the interface gives "Interface 'Post'
incorrectly extends interface 'Timestamps'" — delete that line, and store
`now` itself (not `now.toISOString()`) in makePost.
*/

import { expect, expectTypeOf, it } from 'vitest';
import { complete, createTodo, type Todo } from '@ex/03_objects/objects1.ts';

it('creates todos without a due date', () => {
  const t = createTodo('write tests');
  expect(t).toMatchObject({ title: 'write tests', done: false });
  expect(t.dueDate).toBeUndefined();
});

it('completes without mutating', () => {
  const t = createTodo('ship it');
  const done = complete(t);
  expect(done.done).toBe(true);
  expect(t.done).toBe(false);
  expect(done).not.toBe(t);
});

it('has optional, readonly fields', () => {
  expectTypeOf<Todo['dueDate']>().toEqualTypeOf<string | undefined>();
  const t = createTodo('x');
  // @ts-expect-error todos are immutable
  t.done = true;
  // @ts-expect-error ids never change
  t.id = 99;
});

/* HINT
`readonly dueDate?: string;` — both modifiers on one property.
For `complete`, build a new object with spread syntax:
  return { ...todo, done: true };
*/

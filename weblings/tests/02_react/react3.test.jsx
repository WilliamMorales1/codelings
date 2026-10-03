// @vitest-environment jsdom
import { cleanup, render, screen } from '@testing-library/react';
import { afterEach, expect, test, vi } from 'vitest';
import { TodoList } from '@ex/02_react/react3.jsx';

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

const todos = [
  { id: 7, title: 'buy milk', done: false },
  { id: 3, title: 'call mum', done: true },
  { id: 9, title: 'fix bike', done: false },
];

const items = () => screen.queryAllByRole('listitem').map((li) => li.textContent);

test('shows open todos in order', () => {
  render(<TodoList todos={todos} />);
  expect(items()).toEqual(['buy milk', 'fix bike']);
});

test('showDone shows everything', () => {
  render(<TodoList todos={todos} showDone />);
  expect(items()).toEqual(['buy milk', 'call mum', 'fix bike']);
});

test('an empty list says so', () => {
  render(<TodoList todos={[{ id: 1, title: 'done already', done: true }]} />);
  expect(screen.queryByRole('list')).toBeNull();
  expect(screen.getByText('Nothing to do')).toBeTruthy();
});

test('every item has a key (React logs no warning)', () => {
  const error = vi.spyOn(console, 'error').mockImplementation(() => {});
  render(<TodoList todos={todos} showDone />);
  const keyWarnings = error.mock.calls.filter((args) => args.join(' ').includes('key'));
  expect(keyWarnings).toEqual([]);
});

/* HINT
Filter first: `const visible = showDone ? todos : todos.filter((t) => !t.done);`
Return early with `<p>Nothing to do</p>` when `visible` is empty.
Then map with parentheses, not braces, so the arrow returns the element:
    {visible.map((todo) => <li key={todo.id}>{todo.title}</li>)}
*/

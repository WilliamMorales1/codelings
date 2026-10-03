// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { afterEach, expect, test, vi } from 'vitest';
import { NewTodoForm } from '@ex/02_react/react5.jsx';

afterEach(cleanup);

const input = () => screen.getByLabelText('Title');
const button = () => screen.getByRole('button', { name: 'Add' });

test('typing updates the input', async () => {
  const user = userEvent.setup();
  render(<NewTodoForm onAdd={() => {}} />);
  await user.type(input(), 'water plants');
  expect(input().value).toBe('water plants');
});

test('clicking Add submits the trimmed title and clears the input', async () => {
  const user = userEvent.setup();
  const onAdd = vi.fn();
  render(<NewTodoForm onAdd={onAdd} />);
  await user.type(input(), '  water plants ');
  await user.click(button());
  expect(onAdd).toHaveBeenCalledExactlyOnceWith('water plants');
  expect(input().value).toBe('');
});

test('pressing Enter submits too', async () => {
  const user = userEvent.setup();
  const onAdd = vi.fn();
  render(<NewTodoForm onAdd={onAdd} />);
  await user.type(input(), 'feed cat{Enter}');
  expect(onAdd).toHaveBeenCalledExactlyOnceWith('feed cat');
});

test('Add is disabled for blank titles', async () => {
  const user = userEvent.setup();
  render(<NewTodoForm onAdd={() => {}} />);
  expect(button().disabled).toBe(true);
  await user.type(input(), '   ');
  expect(button().disabled).toBe(true);
  await user.type(input(), 'x');
  expect(button().disabled).toBe(false);
});

test('submitting does not reload the page', async () => {
  const user = userEvent.setup();
  render(<NewTodoForm onAdd={() => {}} />);
  await user.type(input(), 'x');
  // fireEvent returns false when a handler called preventDefault().
  expect(fireEvent.submit(input().closest('form'))).toBe(false);
});

/* HINT
Input: `value={title} onChange={(e) => setTitle(e.target.value)}`.
Move the logic to `<form onSubmit={handleSubmit}>`, where handleSubmit calls
`event.preventDefault()`, then `onAdd(title.trim())` and `setTitle('')`.
Button: `<button type="submit" disabled={!title.trim()}>Add</button>`.
*/

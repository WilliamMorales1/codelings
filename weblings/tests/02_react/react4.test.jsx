// @vitest-environment jsdom
import { cleanup, render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { afterEach, expect, test } from 'vitest';
import { Counter } from '@ex/02_react/react4.jsx';

afterEach(cleanup);

const count = () => screen.getByText(/^Count:/).textContent;
const press = (user, name) => user.click(screen.getByRole('button', { name }));

test('starts at initial', () => {
  render(<Counter initial={4} />);
  expect(count()).toBe('Count: 4');
});

test('"+" adds one step per click', async () => {
  const user = userEvent.setup();
  render(<Counter />);
  await press(user, '+');
  await press(user, '+');
  expect(count()).toBe('Count: 2');
});

test('"+ twice" really adds two steps', async () => {
  const user = userEvent.setup();
  render(<Counter step={5} />);
  await press(user, '+ twice');
  expect(count()).toBe('Count: 10');
});

test('"-" stops at zero', async () => {
  const user = userEvent.setup();
  render(<Counter initial={3} step={2} />);
  await press(user, '-');
  expect(count()).toBe('Count: 1');
  await press(user, '-');
  expect(count()).toBe('Count: 0');
});

test('Reset goes back to initial', async () => {
  const user = userEvent.setup();
  render(<Counter initial={1} />);
  await press(user, '+ twice');
  await press(user, 'Reset');
  expect(count()).toBe('Count: 1');
});

/* HINT
`const [count, setCount] = useState(initial);`
Always update from the previous value: `setCount((c) => c + step)`. Then
calling increment() twice in one click adds two steps.
For "-": `setCount((c) => Math.max(0, c - step))`.
*/

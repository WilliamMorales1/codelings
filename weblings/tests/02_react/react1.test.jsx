// @vitest-environment jsdom
import { cleanup, render, screen } from '@testing-library/react';
import { afterEach, expect, test } from 'vitest';
import { ProfileCard } from '@ex/02_react/react1.jsx';

afterEach(cleanup);

const ada = { name: 'Ada', avatar: '/ada.png', bio: 'Wrote the first program.', joined: 1843 };

test('renders five siblings with no wrapper element', () => {
  const { container } = render(<ProfileCard user={ada} />);
  expect([...container.children].map((el) => el.tagName)).toEqual(['H2', 'IMG', 'LABEL', 'TEXTAREA', 'P']);
});

test('the heading has the title class', () => {
  render(<ProfileCard user={ada} />);
  expect(screen.getByRole('heading', { name: 'Ada' })).toHaveProperty('className', 'title');
});

test('the avatar has src and alt', () => {
  render(<ProfileCard user={ada} />);
  const img = screen.getByAltText("Ada's avatar");
  expect(img.getAttribute('src')).toBe('/ada.png');
});

test('the label is attached to the textarea', () => {
  render(<ProfileCard user={ada} />);
  expect(screen.getByLabelText('Bio').value).toBe('Wrote the first program.');
});

test('the footer is gray', () => {
  render(<ProfileCard user={ada} />);
  expect(screen.getByText('Joined 1843').style.color).toBe('gray');
});

/* HINT
Wrap everything in `<>` ... `</>`. Then: `class` -> `className`, `for` ->
`htmlFor`, `<img ... />` self-closes, and `style={{ color: 'gray' }}` (the
outer braces are "JavaScript here", the inner ones are the object).
*/

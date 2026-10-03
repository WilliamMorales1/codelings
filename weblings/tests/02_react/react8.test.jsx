// @vitest-environment jsdom
import { cleanup, render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { afterEach, expect, test, vi } from 'vitest';
import { Panel, ThemeProvider, ThemeToggle } from '@ex/02_react/react8.jsx';

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

const classes = () => [...document.querySelectorAll('section')].map((s) => s.className);

function App({ initial }) {
  return (
    <ThemeProvider initial={initial}>
      <ThemeToggle />
      <Panel title="one" />
      <div>
        <Panel title="two" />
      </div>
    </ThemeProvider>
  );
}

test('panels start with the initial theme', () => {
  render(<App initial="dark" />);
  expect(classes()).toEqual(['panel panel-dark', 'panel panel-dark']);
});

test('the toggle switches every panel', async () => {
  const user = userEvent.setup();
  render(<App />);
  await user.click(screen.getByRole('button', { name: 'Switch to dark' }));
  expect(classes()).toEqual(['panel panel-dark', 'panel panel-dark']);
  await user.click(screen.getByRole('button', { name: 'Switch to light' }));
  expect(classes()).toEqual(['panel panel-light', 'panel panel-light']);
});

test('using the theme outside a provider is a clear error', () => {
  vi.spyOn(console, 'error').mockImplementation(() => {});
  expect(() => render(<Panel title="lost" />)).toThrow(/ThemeProvider/);
});

/* HINT
Make the default `createContext(null)`, and in useTheme:
    const ctx = useContext(ThemeContext);
    if (!ctx) throw new Error('useTheme must be used inside a <ThemeProvider>');
ThemeProvider should return
    <ThemeContext value={{ theme, toggle }}>{children}</ThemeContext>
*/

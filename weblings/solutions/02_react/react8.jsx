// react8.jsx -- reference solution.

import { createContext, useContext, useState } from 'react';

const ThemeContext = createContext(null);

export function ThemeProvider({ initial = 'light', children }) {
  const [theme, setTheme] = useState(initial);
  const toggle = () => setTheme((t) => (t === 'light' ? 'dark' : 'light'));
  return <ThemeContext value={{ theme, toggle }}>{children}</ThemeContext>;
}

export function useTheme() {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('useTheme must be used inside a <ThemeProvider>');
  return ctx;
}

export function ThemeToggle() {
  const { theme, toggle } = useTheme();
  return <button onClick={toggle}>Switch to {theme === 'light' ? 'dark' : 'light'}</button>;
}

export function Panel({ title }) {
  const { theme } = useTheme();
  return <section className={`panel panel-${theme}`}>{title}</section>;
}

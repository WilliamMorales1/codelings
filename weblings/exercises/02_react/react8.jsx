// react8.jsx
//
// Context: sharing state without prop drilling
//
// `createContext(defaultValue)` makes a context; a component reads the
// nearest provided value with `useContext(Ctx)`. In React 19 the context
// object itself is the provider: `<ThemeContext value={...}>`.
//
// If there is no provider above a component, useContext quietly returns the
// default value. A default that *looks* usable (a no-op toggle, say) hides
// the missing provider; a null default plus a check in your hook turns it
// into a clear error.
//
// Task: make the theme shared.
//   - ThemeProvider holds `theme` ('light' | 'dark', starting at `initial`)
//     and a `toggle` function, and provides them to its children
//   - useTheme() returns { theme, toggle }, and throws an Error mentioning
//     "ThemeProvider" when used outside one
//   - ThemeToggle and Panel already use the hook correctly

import { createContext, useContext, useState } from 'react';

const ThemeContext = createContext({ theme: 'light', toggle: () => {} });

export function ThemeProvider({ initial = 'light', children }) {
  const [theme, setTheme] = useState(initial);
  const toggle = () => setTheme(theme === 'light' ? 'dark' : 'light');
  return children;
}

export function useTheme() {
  return useContext(ThemeContext);
}

export function ThemeToggle() {
  const { theme, toggle } = useTheme();
  return <button onClick={toggle}>Switch to {theme === 'light' ? 'dark' : 'light'}</button>;
}

export function Panel({ title }) {
  const { theme } = useTheme();
  return <section className={`panel panel-${theme}`}>{title}</section>;
}

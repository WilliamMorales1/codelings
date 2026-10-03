// @vitest-environment jsdom
import { act, cleanup, renderHook } from '@testing-library/react';
import { afterEach, beforeEach, expect, test, vi } from 'vitest';
import { useDebounce } from '@ex/02_react/react7.jsx';

beforeEach(() => vi.useFakeTimers());
afterEach(() => {
  cleanup();
  vi.useRealTimers();
});

// Records every value the hook ever returned.
function setup(initial, delay) {
  const seen = [];
  const hook = renderHook(({ value, delay }) => {
    const v = useDebounce(value, delay);
    if (seen.at(-1) !== v) seen.push(v);
    return v;
  }, { initialProps: { value: initial, delay } });
  const type = (value, ms = 0) => {
    hook.rerender({ value, delay });
    act(() => vi.advanceTimersByTime(ms));
  };
  return { hook, seen, type };
}

test('returns the initial value straight away', () => {
  const { hook } = setup('hello', 300);
  expect(hook.result.current).toBe('hello');
});

test('updates only after the value has settled for `delay` ms', () => {
  const { hook, type } = setup('', 300);
  type('c', 299);
  expect(hook.result.current).toBe('');
  act(() => vi.advanceTimersByTime(1));
  expect(hook.result.current).toBe('c');
});

test('fast typing never shows the intermediate values', () => {
  const { seen, type } = setup('', 300);
  type('c', 100);
  type('ca', 100);
  type('cat', 100);
  act(() => vi.advanceTimersByTime(1000));
  expect(seen).toEqual(['', 'cat']);
});

test('no timers are left behind after unmount', () => {
  const { hook, type } = setup('', 300);
  type('a', 10);
  hook.unmount();
  expect(vi.getTimerCount()).toBe(0);
});

/* HINT
Keep the id of the timer and return a cleanup that clears it:
    useEffect(() => {
      const timer = setTimeout(() => setDebounced(value), delay);
      return () => clearTimeout(timer);
    }, [value, delay]);
*/

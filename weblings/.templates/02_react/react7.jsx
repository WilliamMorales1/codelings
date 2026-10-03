// react7.jsx
//
// Custom hooks: useDebounce
//
// A custom hook is a function whose name starts with `use` and that calls
// other hooks. It lets components share stateful logic -- here, "only give
// me this value once it has stopped changing for `delay` ms", the classic
// guard against firing a search request on every keystroke.
//
// Every timer an effect starts must be cleared by the effect's cleanup;
// otherwise the timers of earlier renders still fire, and the "debounced"
// value flickers through every intermediate state.
//
// Task: fix useDebounce(value, delay).
//   - it returns the initial value immediately
//   - after `value` stops changing for `delay` ms it returns the latest value,
//     and never any of the values in between

import { useEffect, useState } from 'react';

export function useDebounce(value, delay) {
  const [debounced, setDebounced] = useState(value);

  useEffect(() => {
    setTimeout(() => setDebounced(value), delay);
  }, [value]);

  return debounced;
}

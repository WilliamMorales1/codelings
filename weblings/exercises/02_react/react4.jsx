// react4.jsx
//
// useState and updater functions
//
// A plain `let` variable in a component is recreated on every render and
// changing it does not re-render anything. State lives in `useState`:
//     const [count, setCount] = useState(initial);
// `setCount(count + 1)` schedules a render with the new value -- but `count`
// in this render stays the same, so calling it twice still adds only one.
// When the next value depends on the previous one, pass a function:
// `setCount((c) => c + 1)`.
//
// Task: make Counter work.
//   "+" adds `step`, "+ twice" adds `step` two times, "-" subtracts `step`
//   but never goes below 0, "Reset" goes back to `initial`.

import { useState } from 'react';

export function Counter({ initial = 0, step = 1 }) {
  let count = initial;

  function increment() {
    count = count + step;
  }

  function incrementTwice() {
    increment();
    increment();
  }

  function decrement() {
    count = count - step;
  }

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={increment}>+</button>
      <button onClick={incrementTwice}>+ twice</button>
      <button onClick={decrement}>-</button>
      <button onClick={() => (count = initial)}>Reset</button>
    </div>
  );
}

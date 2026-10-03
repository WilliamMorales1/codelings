// react4.jsx -- reference solution.

import { useState } from 'react';

export function Counter({ initial = 0, step = 1 }) {
  const [count, setCount] = useState(initial);

  const increment = () => setCount((c) => c + step);

  function incrementTwice() {
    increment();
    increment();
  }

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={increment}>+</button>
      <button onClick={incrementTwice}>+ twice</button>
      <button onClick={() => setCount((c) => Math.max(0, c - step))}>-</button>
      <button onClick={() => setCount(initial)}>Reset</button>
    </div>
  );
}

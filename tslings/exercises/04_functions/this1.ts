// this1 — Typing `this`
//
// A method pulled off its object (`button.onClick(counter.increment)`) loses
// its `this`. In a module (always strict mode) `this` is then undefined and
// `this.count++` throws at runtime.
//
// You can declare what `this` must be with a fake first parameter:
//
//   increment(this: Counter): void
//
// It is erased from the output and doesn't count as an argument. Callbacks
// that will be called bare say so with `(this: void) => void`, like
// `clickTimes` below; passing `c.increment` there is then a compile error.
//
// Task: declare the `this` type on `increment`, then fix the call site the
// compiler points at.
//

export interface Counter {
  count: number;
  increment(): void;
}

export function makeCounter(): Counter {
  return {
    count: 0,
    increment() {
      this.count++;
    },
  };
}

function clickTimes(n: number, handler: (this: void) => void): void {
  for (let i = 0; i < n; i++) handler();
}

export function countClicks(n: number): number {
  const counter = makeCounter();
  clickTimes(n, counter.increment);
  return counter.count;
}

// node1/math.js -- see index.js for the task.

export function add(a, b) {
  return a + b;
}

export function multiply(a, b) {
  return a * b;
}

export function mean(xs) {
  return xs.reduce(add, 0) / xs.length;
}

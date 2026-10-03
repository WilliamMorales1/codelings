// node1/math.js -- reference solution.

export function add(a, b) {
  return a + b;
}

export function multiply(a, b) {
  return a * b;
}

export default function mean(xs) {
  return xs.reduce(add, 0) / xs.length;
}

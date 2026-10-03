// node1/math.js -- see index.js for the task.

function add(a, b) {
  return a + b;
}

function multiply(a, b) {
  return a * b;
}

function mean(xs) {
  return xs.reduce(add, 0) / xs.length;
}

exports.add = add;
exports.multiply = multiply;
exports.default = mean;

// node1/index.js
//
// ES modules in Node
//
// This course's package.json says `"type": "module"`, so every .js file is an
// ES module: `import` / `export`, no `require`, no `module.exports`. Node's
// ESM loader is also stricter than bundlers: relative imports need the full
// file name, extension included.
//
// Task: make this directory a small library.
//   - math.js exports `add` and `multiply` by name, and `mean` as its default export.
//   - index.js (this file) re-exports `add` and `multiply` by name and makes
//     `mean` *its* default export, so users can write
//         import mean, { add, multiply } from './node1/index.js';
//
// The test imports index.js in a fresh `node` process, not through vitest,
// so it sees exactly what Node sees.

export { add, multiply } from "./math.js";
export { default } from "./math.js";
const math = require("./math");

module.exports = {
  add: math.add,
  multiply: math.multiply,
  mean: math.mean,
};

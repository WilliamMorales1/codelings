import { execFileSync } from 'node:child_process';
import { pathToFileURL } from 'node:url';
import { expect, test } from 'vitest';
import { exPath } from '../helpers.js';

// Import in a real node process: vitest would quietly forgive missing extensions.
function probe(file, body) {
  const url = JSON.stringify(pathToFileURL(exPath('01_node', 'node1', file)).href);
  const code = `import mean, * as mod from ${url};\n${body}`;
  try {
    return JSON.parse(execFileSync(process.execPath, ['--input-type=module', '-e', code], { encoding: 'utf8', stdio: 'pipe' }));
  } catch (e) {
    const msg = (e.stderr || e.message).split('\n').find((l) => /Error/.test(l)) ?? e.message;
    throw new Error(`node could not import node1/${file}:\n${msg}`);
  }
}

const report = 'console.log(JSON.stringify({ names: Object.keys(mod).sort(), add: mod.add?.(2, 3), multiply: mod.multiply?.(4, 5), mean: typeof mean === "function" ? mean([1, 2, 6]) : null }))';

test('math.js has named exports and a default export', () => {
  expect(probe('math.js', report)).toEqual({ names: ['add', 'default', 'multiply'], add: 5, multiply: 20, mean: 3 });
});

test('index.js re-exports the same shape', () => {
  expect(probe('index.js', report)).toEqual({ names: ['add', 'default', 'multiply'], add: 5, multiply: 20, mean: 3 });
});

/* HINT
Put `export` in front of each function in math.js (`export default function mean`),
and drop the `exports.x = ...` lines.

index.js can re-export without importing first:
    export { add, multiply } from './math.js';
    export { default } from './math.js';
Mind the `.js` -- Node will not guess extensions for you.
*/

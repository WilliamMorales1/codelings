import { expect, test } from 'vitest';
import { parseCli } from '@ex/01_node/node7.js';

test('no arguments gives the defaults', () => {
  expect(parseCli([])).toEqual({ out: 'out.json', verbose: false, tags: [], limit: Infinity, files: [] });
});

test('long flags, short flags and positionals', () => {
  expect(parseCli(['-v', '-o', 'report.json', '--tag', 'q1', '-t', 'draft', '--limit', '10', 'a.csv', 'b.csv'])).toEqual({
    out: 'report.json',
    verbose: true,
    tags: ['q1', 'draft'],
    limit: 10,
    files: ['a.csv', 'b.csv'],
  });
});

test('--flag=value works too', () => {
  expect(parseCli(['--out=x.json', '--limit=0']).out).toBe('x.json');
  expect(parseCli(['--limit=0']).limit).toBe(0);
});

test('a bad limit is rejected', () => {
  expect(() => parseCli(['--limit', 'lots'])).toThrow(/limit/);
  expect(() => parseCli(['--limit=-3'])).toThrow(/limit/);
  expect(() => parseCli(['--limit', '2.5'])).toThrow(/limit/);
});

test('unknown flags are rejected', () => {
  expect(() => parseCli(['--colour'])).toThrow();
});

/* HINT
Each option can carry `short: 'o'` and `default: ...`. `verbose` is
`type: 'boolean'`; `tag` needs `multiple: true` (and `default: []`).
Pass `allowPositionals: true` next to `options`.
For limit: `Number(values.limit)` and `Number.isInteger(n) && n >= 0`.
(`--limit -3` is refused by parseArgs itself as ambiguous; `--limit=-3`
reaches your check.)
*/

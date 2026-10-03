// node7.js
//
// Command-line arguments with util.parseArgs
//
// `parseArgs` from `node:util` is Node's built-in flag parser. You describe
// each option -- `type: 'string'` or `'boolean'`, a one-letter `short` alias,
// a `default`, `multiple: true` to collect repeats into an array -- and it
// returns `{ values, positionals }`. It is strict by default: unknown flags
// throw, and so do positional arguments unless `allowPositionals` is set.
// Everything arrives as a string; converting is your job.
//
// Task: parseCli(argv) for a tool used like
//     convert -v -o report.json --tag q1 -t draft --limit 10 a.csv b.csv
// returns
//     { out: 'report.json', verbose: true, tags: ['q1', 'draft'], limit: 10, files: ['a.csv', 'b.csv'] }
// Defaults: out 'out.json', verbose false, tags [], limit Infinity, files [].
// `--limit` must be a non-negative integer; otherwise throw an Error whose
// message mentions "limit".

import { parseArgs } from 'node:util';

export function parseCli(argv) {
  const { values, positionals } = parseArgs({
    args: argv,
    options: {
      out: { type: 'string' },
      verbose: { type: 'string' },
      tag: { type: 'string' },
      limit: { type: 'string' },
    },
  });

  return {
    out: values.out,
    verbose: values.verbose,
    tags: values.tag,
    limit: values.limit,
    files: positionals,
  };
}

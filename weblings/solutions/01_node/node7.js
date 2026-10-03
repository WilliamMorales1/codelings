// node7.js -- reference solution.

import { parseArgs } from 'node:util';

export function parseCli(argv) {
  const { values, positionals } = parseArgs({
    args: argv,
    options: {
      out: { type: 'string', short: 'o', default: 'out.json' },
      verbose: { type: 'boolean', short: 'v', default: false },
      tag: { type: 'string', short: 't', multiple: true, default: [] },
      limit: { type: 'string', short: 'n' },
    },
    allowPositionals: true,
  });

  let limit = Infinity;
  if (values.limit !== undefined) {
    limit = Number(values.limit);
    if (!Number.isInteger(limit) || limit < 0) {
      throw new Error(`--limit must be a non-negative integer, got "${values.limit}"`);
    }
  }

  return { out: values.out, verbose: values.verbose, tags: values.tag, limit, files: positionals };
}

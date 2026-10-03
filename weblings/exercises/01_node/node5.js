// node5.js
//
// Streams: Transform and pipeline
//
// A Transform stream receives chunks in `transform(chunk, encoding, callback)`
// and pushes output with `this.push(...)`. Chunks are arbitrary slices of the
// input -- a line of text can be split across two of them -- so a line-based
// transform has to carry the unfinished tail over to the next chunk, and
// push whatever is left in `flush(callback)` at the end.
//
// `pipeline(a, b, c)` from `node:stream/promises` connects streams, destroys
// all of them if any one fails, and returns a Promise. `a.pipe(b)` does none
// of that.
//
// Task: csvToNdjson() turns CSV text (first line = header, plain commas, no
// quoting) into newline-delimited JSON, one object per row. convert(input,
// output) pipes input through it into output and resolves when done, or
// rejects if any stream errors.

import { Transform } from 'node:stream';
import { pipeline } from 'node:stream/promises';

export function csvToNdjson() {
  let header = null;
  return new Transform({
    transform(chunk, encoding, callback) {
      for (const line of chunk.toString().split('\n')) {
        if (!line) continue;
        const cells = line.split(',');
        if (!header) {
          header = cells;
          continue;
        }
        const row = Object.fromEntries(header.map((h, i) => [h, cells[i]]));
        this.push(JSON.stringify(row) + '\n');
      }
      callback();
    },
  });
}

export function convert(input, output) {
  input.pipe(csvToNdjson()).pipe(output);
}

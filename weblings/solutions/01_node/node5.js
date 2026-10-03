// node5.js -- reference solution.

import { Transform } from 'node:stream';
import { pipeline } from 'node:stream/promises';

export function csvToNdjson() {
  let header = null;
  let rest = '';

  function emit(stream, line) {
    if (!line) return;
    const cells = line.split(',');
    if (!header) {
      header = cells;
      return;
    }
    const row = Object.fromEntries(header.map((h, i) => [h, cells[i]]));
    stream.push(JSON.stringify(row) + '\n');
  }

  return new Transform({
    transform(chunk, encoding, callback) {
      const lines = (rest + chunk.toString()).split('\n');
      rest = lines.pop();
      for (const line of lines) emit(this, line);
      callback();
    },
    flush(callback) {
      emit(this, rest);
      callback();
    },
  });
}

export function convert(input, output) {
  return pipeline(input, csvToNdjson(), output);
}

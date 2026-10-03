import { Readable, Writable } from 'node:stream';
import { expect, test } from 'vitest';
import { convert, csvToNdjson } from '@ex/01_node/node5.js';

function sink() {
  const chunks = [];
  const stream = new Writable({
    write(chunk, enc, cb) {
      chunks.push(chunk.toString());
      cb();
    },
  });
  return { stream, text: () => chunks.join('') };
}

const lines = (s) => s.trim().split('\n').map((l) => JSON.parse(l));

test('converts rows that arrive in one piece', async () => {
  const out = sink();
  await convert(Readable.from(['name,lang\nada,en\nlinus,fi\n']), out.stream);
  expect(lines(out.text())).toEqual([
    { name: 'ada', lang: 'en' },
    { name: 'linus', lang: 'fi' },
  ]);
});

test('rows split across chunks are glued back together', async () => {
  const out = sink();
  await convert(Readable.from(['na', 'me,age\nal', 'ice,30\nbob,4', '1\n']), out.stream);
  expect(lines(out.text())).toEqual([
    { name: 'alice', age: '30' },
    { name: 'bob', age: '41' },
  ]);
});

test('the last row does not need a trailing newline', async () => {
  const out = sink();
  await convert(Readable.from(['id\n1\n2']), out.stream);
  expect(lines(out.text())).toEqual([{ id: '1' }, { id: '2' }]);
});

test('each output line is one JSON document', async () => {
  const out = sink();
  await convert(Readable.from(['a,b\n1,2\n']), out.stream);
  expect(out.text()).toBe('{"a":"1","b":"2"}\n');
});

test('convert rejects when the source fails', async () => {
  async function* broken() {
    yield 'a,b\n1,2\n';
    throw new Error('disk on fire');
  }
  await expect(convert(Readable.from(broken()), sink().stream)).rejects.toThrow('disk on fire');
});

test('csvToNdjson works with plain pipe too', async () => {
  const t = csvToNdjson();
  const done = Readable.from(['x\n4', '2']).pipe(t).toArray();
  expect((await done).join('')).toBe('{"x":"42"}\n');
});

/* HINT
Keep a `rest` string outside transform(). Each chunk:
    const parts = (rest + chunk.toString()).split('\n');
    rest = parts.pop();          // maybe an unfinished line
    ...handle the complete lines in `parts`...
Add `flush(callback)` that handles `rest`, then calls callback().
convert: `return pipeline(input, csvToNdjson(), output);`
*/

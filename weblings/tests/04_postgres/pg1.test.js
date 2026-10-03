import { afterAll, beforeAll, expect, test } from 'vitest';
import { freshPg, readEx } from '../helpers.js';

let db;
beforeAll(async () => {
  db = await freshPg('shop.sql');
});
afterAll(() => db?.close());

test('two in-stock books under 45, most expensive first', async () => {
  const { rows } = await db.query(readEx('04_postgres', 'pg1.sql'));
  expect(rows).toEqual([
    { name: 'The C Programming Language', price: '39.99' },
    { name: 'Learn You a Haskell', price: '19.99' },
  ]);
});

/* HINT
'books' in single quotes. Add `AND stock > 0`, and sort with
`ORDER BY price DESC`.
*/

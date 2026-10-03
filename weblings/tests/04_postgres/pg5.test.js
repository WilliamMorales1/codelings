import { afterAll, beforeAll, expect, test } from 'vitest';
import { freshPg, readEx } from '../helpers.js';

let db;
beforeAll(async () => {
  db = await freshPg('shop.sql');
});
afterAll(() => db?.close());

test('top two per category with rank and share', async () => {
  const { rows } = await db.query(readEx('04_postgres', 'pg5.sql'));
  const norm = rows.map((r) => [r.category, r.name, r.price, Number(r.rank), Number(r.share)]);
  expect(norm).toEqual([
    ['accessories', 'Rubber Duck', '4.99', 1, 59],
    ['accessories', 'Sticker Pack', '3.50', 2, 41],
    ['books', 'SICP', '45.00', 1, 33],
    ['books', 'The C Programming Language', '39.99', 2, 30],
    ['hardware', 'Mechanical Keyboard', '129.00', 1, 39],
    ['hardware', 'Travel Keyboard', '79.00', 2, 24],
  ]);
});

/* HINT
    WITH ranked AS (
      SELECT category, name, price,
             rank() OVER (PARTITION BY category ORDER BY price DESC) AS rank,
             round(100 * price / sum(price) OVER (PARTITION BY category)) AS share
      FROM products
    )
    SELECT ... FROM ranked WHERE rank <= 2 ORDER BY category, rank;
*/

import { afterAll, beforeAll, expect, test } from 'vitest';
import { freshPg, readEx } from '../helpers.js';

let db;
beforeAll(async () => {
  db = await freshPg('shop.sql');
});
afterAll(() => db?.close());

test('customers with over 100 in non-cancelled orders', async () => {
  const { rows } = await db.query(readEx('04_postgres', 'pg3.sql'));
  expect(rows.map((r) => ({ name: r.name, orders: Number(r.orders), revenue: Number(r.revenue) }))).toEqual([
    { name: 'Grace Hopper', orders: 2, revenue: 232.97 },
    { name: 'Ada Lovelace', orders: 2, revenue: 183.98 },
  ]);
});

/* HINT
Filter rows with `WHERE o.status <> 'cancelled'`, then
`GROUP BY c.id, c.name`, then filter groups with
`HAVING sum(i.quantity * i.unit_price) > 100`.
Count orders with `count(DISTINCT o.id)`.
*/

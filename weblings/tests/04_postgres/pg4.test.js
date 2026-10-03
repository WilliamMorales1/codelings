import { afterAll, beforeAll, expect, test } from 'vitest';
import { freshPg, readEx } from '../helpers.js';

let db;
beforeAll(async () => {
  db = await freshPg();
  await db.exec(`CREATE TABLE inventory (
    sku text PRIMARY KEY,
    quantity integer NOT NULL CHECK (quantity >= 0),
    restocked_at timestamptz NOT NULL DEFAULT now()
  )`);
});
afterAll(() => db?.close());

const deliver = async (sku, qty) => (await db.query(readEx('04_postgres', 'pg4.sql'), [sku, qty])).rows;

test('a new sku is inserted', async () => {
  expect(await deliver('duck', 5)).toEqual([{ sku: 'duck', quantity: 5 }]);
});

test('a known sku adds up', async () => {
  await deliver('mug', 2);
  expect(await deliver('mug', 3)).toEqual([{ sku: 'mug', quantity: 5 }]);
  expect(await deliver('mug', 10)).toEqual([{ sku: 'mug', quantity: 15 }]);
  const { rows } = await db.query("SELECT count(*)::int AS n FROM inventory WHERE sku = 'mug'");
  expect(rows[0].n).toBe(1);
});

test('restocked_at moves forward on a repeat delivery', async () => {
  await deliver('pen', 1);
  await db.query("UPDATE inventory SET restocked_at = '2000-01-01' WHERE sku = 'pen'");
  await deliver('pen', 1);
  const { rows } = await db.query("SELECT restocked_at FROM inventory WHERE sku = 'pen'");
  expect(rows[0].restocked_at.getFullYear()).toBeGreaterThan(2000);
});

/* HINT
Name the conflict target and say what to update:
    ON CONFLICT (sku) DO UPDATE
      SET quantity = inventory.quantity + EXCLUDED.quantity,
          restocked_at = now()
*/

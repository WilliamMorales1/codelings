import { afterAll, beforeAll, expect, test } from 'vitest';
import { freshPg, pgError, readEx } from '../helpers.js';

let db;
beforeAll(async () => {
  db = await freshPg('shop.sql');
  await db.exec(readEx('04_postgres', 'pg7.sql'));
});
afterAll(() => db?.close());

const indexdef = async (name) =>
  (await db.query('SELECT indexdef FROM pg_indexes WHERE indexname = $1', [name])).rows[0]?.indexdef ?? '(no such index)';

// With seq scans disabled, the plan shows whether the index *can* serve the query.
async function plan(sql) {
  await db.exec('SET enable_seqscan = off');
  const { rows } = await db.query(`EXPLAIN ${sql}`);
  await db.exec('RESET enable_seqscan');
  return rows.map((r) => r['QUERY PLAN']).join('\n');
}

test('the email index is unique and on lower(email)', async () => {
  const def = await indexdef('customers_email_lower_idx');
  expect(def).toMatch(/^CREATE UNIQUE INDEX/);
  expect(def).toContain('lower(email)');
});

test('emails are now unique regardless of case', async () => {
  const err = await pgError(() => db.query("INSERT INTO customers (name, email, country) VALUES ('Fake Ada', 'ADA@Example.com', 'UK')"));
  expect(err?.code).toBe('23505');
});

test('case-insensitive lookups can use the index', async () => {
  expect(await plan("SELECT * FROM customers WHERE lower(email) = 'ada@example.com'")).toContain('customers_email_lower_idx');
});

test('the pending-orders index is partial', async () => {
  const def = await indexdef('orders_pending_customer_idx');
  expect(def).toContain('(customer_id)');
  expect(def).toMatch(/WHERE \(status = 'pending'::text\)/);
});

test('pending-order lookups can use it', async () => {
  expect(await plan("SELECT * FROM orders WHERE customer_id = 2 AND status = 'pending'")).toContain('orders_pending_customer_idx');
});

/* HINT
Index the expression, with its own parentheses: `ON customers (lower(email))`.
For the partial one, index only customer_id and add the condition at the end:
`ON orders (customer_id) WHERE status = 'pending'`.
*/

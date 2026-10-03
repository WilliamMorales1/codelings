import { afterAll, beforeAll, expect, test } from 'vitest';
import { addCustomer, customersIn, findCustomerByEmail } from '@ex/04_postgres/pg9.js';
import { freshPg } from '../helpers.js';

let db;
beforeAll(async () => {
  db = await freshPg('shop.sql');
});
afterAll(() => db?.close());

test('finds a customer by email', async () => {
  expect(await findCustomerByEmail(db, 'grace@example.com')).toEqual({ id: 3, name: 'Grace Hopper', email: 'grace@example.com' });
  expect(await findCustomerByEmail(db, 'nobody@example.com')).toBeNull();
});

test('an injection attempt matches nothing', async () => {
  expect(await findCustomerByEmail(db, "' OR '1'='1")).toBeNull();
});

test('names with quotes are stored as-is', async () => {
  const id = await addCustomer(db, { name: "Miles O'Brien", email: 'miles@example.com', country: 'IE' });
  expect(typeof id).toBe('number');
  const { rows } = await db.query('SELECT name FROM customers WHERE id = $1', [id]);
  expect(rows[0].name).toBe("Miles O'Brien");
});

test('a malicious name cannot drop anything', async () => {
  await addCustomer(db, { name: "x'); DELETE FROM orders; --", email: 'bobby@example.com', country: 'US' }).catch(() => {});
  const { rows } = await db.query('SELECT count(*)::int AS n FROM orders');
  expect(rows[0].n).toBe(8);
});

test('customersIn takes a list', async () => {
  expect(await customersIn(db, ['UK', 'FI'])).toEqual(['Ada Lovelace', 'Linus Torvalds', 'Tim Berners-Lee']);
  expect(await customersIn(db, [])).toEqual([]);
});

/* HINT
Placeholders plus a values array:
    db.query('SELECT id, name, email FROM customers WHERE email = $1', [email])
    db.query('INSERT ... VALUES ($1, $2, $3) RETURNING id', [name, email, country])
    db.query('... WHERE country = ANY($1) ORDER BY name', [countries])
*/

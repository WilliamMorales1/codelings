import { afterAll, beforeAll, expect, test } from 'vitest';
import { freshPg, readEx } from '../helpers.js';

let db;
let results;
let error;
beforeAll(async () => {
  db = await freshPg('shop.sql');
  try {
    results = await db.exec(readEx('04_postgres', 'pg6.sql'));
  } catch (e) {
    error = e;
  }
});
afterAll(() => db?.close());

const result = (i) => {
  if (error) throw error;
  expect(results.length, 'the file should contain exactly two queries').toBe(2);
  return results[i].rows;
};

test('wireless products, lightest first, with proper types', () => {
  expect(result(0)).toEqual([
    { name: 'Wireless Mouse', color: 'white', weight_g: 95 },
    { name: 'Trackball', color: 'black', weight_g: 180 },
    { name: 'Travel Keyboard', color: 'grey', weight_g: 450 },
  ]);
});

test('colors per category as one JSON object', () => {
  expect(result(1)).toEqual([
    { category: 'accessories', colors: { 'Rubber Duck': 'yellow' } },
    {
      category: 'hardware',
      colors: {
        'Mechanical Keyboard': 'black',
        'Travel Keyboard': 'grey',
        Trackball: 'black',
        'USB-C Hub': 'silver',
        'Wireless Mouse': 'white',
      },
    },
  ]);
});

/* HINT
Query 1: `attrs ->> 'color'` (text, no quotes), `(attrs ->> 'weight_g')::int`,
and `WHERE attrs @> '{"wireless": true}'`.
Query 2: keep only rows that have the key: `WHERE attrs ? 'color'`.
*/

import { beforeEach, expect, test } from 'vitest';
import { transfer } from '@ex/05_sqlite/sqlite3.js';
import { sqlite } from '../helpers.js';

let db;
beforeEach(async () => {
  db = await sqlite();
  db.exec(`CREATE TABLE accounts (id TEXT PRIMARY KEY, balance INTEGER NOT NULL CHECK (balance >= 0)) STRICT;
           INSERT INTO accounts VALUES ('alice', 100), ('bob', 20);`);
});

const balances = () => Object.fromEntries(db.prepare('SELECT id, balance FROM accounts ORDER BY id').all().map((r) => [r.id, r.balance]));

test('a valid transfer moves money', () => {
  transfer(db, 'alice', 'bob', 30);
  expect(balances()).toEqual({ alice: 70, bob: 50 });
  expect(db.isTransaction).toBe(false);
});

test('insufficient funds changes nothing', () => {
  expect(() => transfer(db, 'bob', 'alice', 50)).toThrow(/CHECK constraint failed/);
  expect(balances()).toEqual({ alice: 100, bob: 20 });
  expect(db.isTransaction).toBe(false);
});

test('an unknown sender changes nothing', () => {
  expect(() => transfer(db, 'mallory', 'alice', 10)).toThrow(/mallory/);
  expect(balances()).toEqual({ alice: 100, bob: 20 });
  expect(db.isTransaction).toBe(false);
});

test('an unknown receiver changes nothing', () => {
  expect(() => transfer(db, 'alice', 'nobody', 10)).toThrow(/nobody/);
  expect(balances()).toEqual({ alice: 100, bob: 20 });
});

/* HINT
    db.exec('BEGIN');
    try {
      ...both updates, throwing on problems...
      db.exec('COMMIT');
    } catch (err) {
      db.exec('ROLLBACK');
      throw err;
    }
*/

import { beforeEach, expect, test } from 'vitest';
import { readEx, sqlite } from '../helpers.js';

let db;
let hit;
beforeEach(async () => {
  db = await sqlite();
  db.exec(`CREATE TABLE page_views (
    path TEXT PRIMARY KEY,
    views INTEGER NOT NULL,
    first_seen TEXT NOT NULL DEFAULT (datetime('now'))
  ) STRICT`);
  const stmt = db.prepare(readEx('05_sqlite', 'sqlite4.sql'));
  hit = (path) => stmt.get({ path })?.views;
});

test('the first view returns 1', () => {
  expect(hit('/home')).toBe(1);
});

test('views add up per path', () => {
  expect([hit('/a'), hit('/a'), hit('/b'), hit('/a')]).toEqual([1, 2, 1, 3]);
});

test('first_seen survives later views', () => {
  hit('/old');
  db.exec("UPDATE page_views SET first_seen = '2001-01-01 00:00:00' WHERE path = '/old'");
  hit('/old');
  expect(db.prepare("SELECT first_seen FROM page_views WHERE path = '/old'").get().first_seen).toBe('2001-01-01 00:00:00');
});

/* HINT
Replace `OR REPLACE` with a real conflict clause:
    INSERT INTO page_views (path, views) VALUES (:path, 1)
    ON CONFLICT (path) DO UPDATE SET views = views + 1
    RETURNING views;
*/

import { beforeEach, expect, test } from 'vitest';
import { MIGRATIONS, migrate } from '@ex/05_sqlite/sqlite7.js';
import { sqlite } from '../helpers.js';

let db;
beforeEach(async () => {
  db = await sqlite();
});

const version = () => db.prepare('PRAGMA user_version').get().user_version;
const tables = () => db.prepare("SELECT name FROM sqlite_schema WHERE type = 'table' ORDER BY name").all().map((r) => r.name);
const columns = (t) => db.prepare(`PRAGMA table_info(${t})`).all().map((c) => c.name);

test('a fresh database gets every migration', () => {
  expect(migrate(db)).toBe(3);
  expect(version()).toBe(3);
  expect(tables()).toEqual(['sessions', 'users']);
  expect(columns('users')).toEqual(['id', 'email', 'name']);
});

test('running it again is a no-op', () => {
  migrate(db);
  expect(migrate(db)).toBe(0);
  expect(version()).toBe(3);
});

test('only pending migrations run', () => {
  migrate(db, MIGRATIONS.slice(0, 1));
  expect(version()).toBe(1);
  db.exec("INSERT INTO users (email) VALUES ('ada@example.com')");
  expect(migrate(db)).toBe(2);
  expect(db.prepare('SELECT email, name FROM users').get()).toEqual({ email: 'ada@example.com', name: null });
});

test('a failing migration stops cleanly at the last good version', () => {
  const broken = [...MIGRATIONS, 'CREATE TABLE audit (id INTEGER PRIMARY KEY)', 'ALTER TABLE nope ADD COLUMN x TEXT'];
  expect(() => migrate(db, broken)).toThrow(/no such table/);
  expect(version()).toBe(4);
  expect(tables()).toContain('audit');
  expect(db.isTransaction).toBe(false);
});

test('a failed migration leaves no partial changes', () => {
  const partial = [`CREATE TABLE a (x INTEGER); CREATE TABLE b (y INTEGER); INSERT INTO nope VALUES (1);`];
  expect(() => migrate(db, partial)).toThrow();
  expect(tables()).toEqual([]);
  expect(version()).toBe(0);
});

/* HINT
Read the current version with
    db.prepare('PRAGMA user_version').get().user_version
and loop from there. For each migration:
    db.exec('BEGIN');
    try { db.exec(sql); db.exec(`PRAGMA user_version = ${v + 1}`); db.exec('COMMIT'); }
    catch (err) { db.exec('ROLLBACK'); throw err; }
*/

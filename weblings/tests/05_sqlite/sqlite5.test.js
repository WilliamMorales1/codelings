import { beforeEach, expect, test } from 'vitest';
import { buildIndex, search } from '@ex/05_sqlite/sqlite5.js';
import { sqlite } from '../helpers.js';

let db;
beforeEach(async () => {
  db = await sqlite();
  db.exec(`CREATE TABLE articles (id INTEGER PRIMARY KEY, title TEXT NOT NULL, body TEXT NOT NULL);
    INSERT INTO articles VALUES
      (1, 'Running SQLite in production', 'Many sites run SQLite happily. It runs in-process and is fast.'),
      (2, 'Pruning your garden', 'Winter pruning keeps fruit trees healthy.'),
      (3, 'Why Postgres', 'When one server is not enough, Postgres runs well.'),
      (4, 'A short history of databases', 'From IMS to SQLite, via relational theory.'),
      (10, 'Fast full-text search', 'FTS5 makes search in SQLite fast and ranked.');`);
  buildIndex(db);
});

const ids = (q) => search(db, q).map((r) => r.id);

test('the index is a real FTS5 table', () => {
  const row = db.prepare("SELECT sql FROM sqlite_schema WHERE name = 'articles_fts'").get();
  expect(row?.sql).toMatch(/USING fts5/i);
  expect(row.sql).toMatch(/porter/);
});

test('stemming: "run" finds running and runs, but not pruning', () => {
  const found = ids('run');
  expect(found.sort()).toEqual([1, 3]);
});

test('ids come from articles, even when they have gaps', () => {
  expect(ids('ranked')).toEqual([10]);
});

test('boolean queries and phrases', () => {
  expect(ids('sqlite AND fast').sort()).toEqual([1, 10]);
  expect(ids('sqlite NOT fast')).toEqual([4]);
  expect(ids('"relational theory"')).toEqual([4]);
});

test('the best match comes first', () => {
  expect(ids('sqlite')[0]).toBe(1);
});

test('snippets highlight the title', () => {
  expect(search(db, 'running')[0]).toEqual({ id: 1, title: 'Running SQLite in production', snippet: '[Running] SQLite in production' });
});

/* HINT
buildIndex:
    CREATE VIRTUAL TABLE articles_fts USING fts5(title, body, tokenize = 'porter');
    INSERT INTO articles_fts (rowid, title, body) SELECT id, title, body FROM articles;
search:
    SELECT rowid AS id, title, highlight(articles_fts, 0, '[', ']') AS snippet
    FROM articles_fts WHERE articles_fts MATCH ? ORDER BY rank
*/

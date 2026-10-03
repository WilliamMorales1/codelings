import { beforeEach, expect, test } from 'vitest';
import { readEx, sqlite } from '../helpers.js';

let db;
beforeEach(async () => {
  db = await sqlite();
  db.exec(readEx('05_sqlite', 'sqlite2.sql'));
  db.exec("INSERT INTO authors (id, name) VALUES (1, 'Ursula K. Le Guin')");
});

const addBook = (year, author = 1) =>
  db.prepare('INSERT INTO books (title, year, author_id) VALUES (?, ?, ?)').run('The Dispossessed', year, author);

test('valid rows go in', () => {
  addBook(1974);
  expect(db.prepare('SELECT count(*) AS n FROM books').get().n).toBe(1);
});

test('text in an INTEGER column is rejected', () => {
  expect(() => addBook('nineteen seventy-four')).toThrow(/cannot store TEXT value in INTEGER column/);
});

test('foreign keys are enforced', () => {
  expect(db.prepare('PRAGMA foreign_keys').get().foreign_keys).toBe(1);
  expect(() => addBook(1974, 99)).toThrow(/FOREIGN KEY constraint failed/);
});

test("deleting an author deletes their books", () => {
  addBook(1974);
  db.exec('DELETE FROM authors WHERE id = 1');
  expect(db.prepare('SELECT count(*) AS n FROM books').get().n).toBe(0);
});

/* HINT
Put `PRAGMA foreign_keys = ON;` at the top, add `STRICT` after each closing
`)`, and declare the key inline:
    author_id INTEGER NOT NULL REFERENCES authors (id) ON DELETE CASCADE
*/

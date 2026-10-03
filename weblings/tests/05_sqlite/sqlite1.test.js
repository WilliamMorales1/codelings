import { beforeEach, expect, test } from 'vitest';
import { addNote, getNote, searchTitles } from '@ex/05_sqlite/sqlite1.js';
import { sqlite } from '../helpers.js';

let db;
beforeEach(async () => {
  db = await sqlite();
  db.exec('CREATE TABLE notes (id INTEGER PRIMARY KEY, title TEXT NOT NULL, body TEXT NOT NULL)');
});

test('addNote returns the new id and getNote reads it back', () => {
  const id = addNote(db, 'shopping', 'milk, eggs');
  expect(id).toBe(1);
  expect(getNote(db, id)).toEqual({ id: 1, title: 'shopping', body: 'milk, eggs' });
});

test('getNote returns null for a missing id', () => {
  expect(getNote(db, 42)).toBeNull();
});

test('quotes in values are just text', () => {
  const id = addNote(db, "Bobby's notes", 'it\'s "fine"');
  expect(getNote(db, id).title).toBe("Bobby's notes");
});

test('searchTitles matches substrings, case-insensitively, sorted', () => {
  addNote(db, 'Weekly plan', '');
  addNote(db, 'plants to water', '');
  addNote(db, 'recipes', '');
  expect(searchTitles(db, 'plan')).toEqual(['Weekly plan', 'plants to water']);
});

test('searchTitles is not an injection hole', () => {
  addNote(db, 'secret', 'x');
  expect(searchTitles(db, "' OR 1=1 --")).toEqual([]);
});

/* HINT
    db.prepare('INSERT INTO notes (title, body) VALUES (?, ?)').run(title, body)
returns { changes, lastInsertRowid } -- use Number(lastInsertRowid).
`.get(id)` returns undefined for no row; turn that into null.
For LIKE, build the pattern around the placeholder: `LIKE '%' || ? || '%'`
(or pass `%${word}%` as the value).
*/

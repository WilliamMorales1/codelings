// sqlite1.js
//
// node:sqlite and prepared statements
//
// Node ships SQLite: `import { DatabaseSync } from 'node:sqlite'`. It is
// synchronous -- SQLite runs in-process, so there is no network to wait on.
// `db.prepare(sql)` compiles a statement once; then run it as often as you
// like with values bound to `?` (or `:name`) placeholders:
//     stmt.run(...values)   -> { changes, lastInsertRowid }
//     stmt.get(...values)   -> first row or undefined
//     stmt.all(...values)   -> array of rows
// Bound values are data, never SQL, so quotes in them are harmless.
//
// The table (created by the test):
//   notes (id INTEGER PRIMARY KEY, title TEXT NOT NULL, body TEXT NOT NULL)
//
// Task: rewrite the three functions with prepared statements and placeholders.
//   addNote(db, title, body)  -> the new note's id (a number)
//   getNote(db, id)           -> { id, title, body } or null
//   searchTitles(db, word)    -> titles containing `word` (case-insensitive,
//                                SQLite's LIKE default), sorted by title

export function addNote(db, title, body) {
  db.exec(`INSERT INTO notes (title, body) VALUES ('${title}', '${body}')`);
  return db.prepare('SELECT max(id) AS id FROM notes').get().id;
}

export function getNote(db, id) {
  return db.prepare(`SELECT * FROM notes WHERE id = ${id}`).get();
}

export function searchTitles(db, word) {
  return db
    .prepare(`SELECT title FROM notes WHERE title LIKE '%${word}%' ORDER BY title`)
    .all()
    .map((r) => r.title);
}

// sqlite1.js -- reference solution.

export function addNote(db, title, body) {
  const { lastInsertRowid } = db.prepare('INSERT INTO notes (title, body) VALUES (?, ?)').run(title, body);
  return Number(lastInsertRowid);
}

export function getNote(db, id) {
  const row = db.prepare('SELECT id, title, body FROM notes WHERE id = ?').get(id);
  return row ? { ...row } : null;
}

export function searchTitles(db, word) {
  return db
    .prepare("SELECT title FROM notes WHERE title LIKE '%' || ? || '%' ORDER BY title")
    .all(word)
    .map((r) => r.title);
}

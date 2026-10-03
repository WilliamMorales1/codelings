// sqlite5.js -- reference solution.

export function buildIndex(db) {
  db.exec(`
    CREATE VIRTUAL TABLE articles_fts USING fts5(title, body, tokenize = 'porter');
    INSERT INTO articles_fts (rowid, title, body) SELECT id, title, body FROM articles;
  `);
}

export function search(db, q) {
  return db
    .prepare(
      `SELECT rowid AS id, title, highlight(articles_fts, 0, '[', ']') AS snippet
       FROM articles_fts
       WHERE articles_fts MATCH ?
       ORDER BY rank`,
    )
    .all(q)
    .map((r) => ({ ...r }));
}

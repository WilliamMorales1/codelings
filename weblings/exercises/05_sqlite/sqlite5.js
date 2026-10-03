// sqlite5.js
//
// Full-text search with FTS5
//
// `LIKE '%run%'` scans every row, cannot rank results, and matches "prune"
// but not "ran". SQLite's FTS5 extension builds a real search index:
//     CREATE VIRTUAL TABLE docs_fts USING fts5(title, body, tokenize = 'porter');
// The porter tokenizer stems English words, so "running", "runs" and "run"
// all match `run`. Query with MATCH, which understands words, "phrases",
// AND / OR / NOT and prefix* searches, and sort by the built-in `rank`
// column (best match first). highlight(table, column, open, close) marks
// the matched words.
//
// The table (created by the test):
//   articles (id INTEGER PRIMARY KEY, title TEXT NOT NULL, body TEXT NOT NULL)
//
// Task:
//   buildIndex(db)   creates articles_fts (title, body, porter tokenizer),
//                    with rowid = articles.id, filled from articles
//   search(db, q)    runs the FTS5 query q and returns
//                    [{ id, title, snippet }] best match first, where
//                    snippet is the title with matches wrapped in [ ]

export function buildIndex(db) {
  // TODO: create and fill articles_fts
}

export function search(db, q) {
  return db
    .prepare("SELECT id, title, title AS snippet FROM articles WHERE title LIKE '%' || ? || '%' OR body LIKE '%' || ? || '%'")
    .all(q, q)
    .map((r) => ({ ...r }));
}

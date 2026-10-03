-- sqlite2.sql
--
-- STRICT tables and foreign keys in SQLite
--
-- By default SQLite is relaxed about types: a column declared INTEGER will
-- happily store the text 'abc'. Adding STRICT after the closing parenthesis
-- makes the declared types (INTEGER, REAL, TEXT, BLOB, ANY) binding.
--
-- Foreign keys are also *off* by default, for backwards compatibility, and
-- must be switched on per connection: PRAGMA foreign_keys = ON;
--
-- Task: make both tables STRICT, give books.author_id a foreign key to
-- authors(id) that deletes an author's books with the author, and switch
-- foreign keys on (the test runs this file on its own connection).
-- Try it: `sqlite3 :memory: < sqlite2.sql` if you have the sqlite CLI.

CREATE TABLE authors (
  id   INTEGER PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE books (
  id        INTEGER PRIMARY KEY,
  title     TEXT NOT NULL,
  year      INTEGER NOT NULL,
  author_id INTEGER NOT NULL
);

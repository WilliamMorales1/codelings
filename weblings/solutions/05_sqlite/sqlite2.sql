-- sqlite2.sql -- reference solution.

PRAGMA foreign_keys = ON;

CREATE TABLE authors (
  id   INTEGER PRIMARY KEY,
  name TEXT NOT NULL
) STRICT;

CREATE TABLE books (
  id        INTEGER PRIMARY KEY,
  title     TEXT NOT NULL,
  year      INTEGER NOT NULL,
  author_id INTEGER NOT NULL REFERENCES authors (id) ON DELETE CASCADE
) STRICT;

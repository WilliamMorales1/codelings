-- sqlite4.sql
--
-- Upsert and RETURNING in SQLite
--
-- `INSERT OR REPLACE` looks like an upsert but is not: on a conflict it
-- DELETES the old row and inserts a fresh one, so every column you did not
-- supply goes back to its default (and ON DELETE triggers/cascades fire).
-- The real upsert is the same syntax as Postgres:
--   INSERT ... ON CONFLICT (col) DO UPDATE SET x = x + excluded.x
-- and `RETURNING` gives you the resulting row in the same statement.
--
-- The table (created by the test):
--   page_views (path TEXT PRIMARY KEY, views INTEGER NOT NULL,
--               first_seen TEXT NOT NULL DEFAULT (datetime('now'))) STRICT
--
-- Task: count one view of :path. The first view inserts views = 1; later
-- ones add 1 and keep first_seen. Return the new `views`.
-- The test runs it with a named parameter: stmt.get({ path: '/home' }).

INSERT OR REPLACE INTO page_views (path, views)
VALUES (:path, 1)
RETURNING views;

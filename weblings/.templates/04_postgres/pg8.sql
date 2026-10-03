-- pg8.sql
--
-- PL/pgSQL triggers: keeping updated_at honest
--
-- A trigger runs a function when rows change. In a row-level BEFORE trigger
-- the function sees the new row as NEW (and the old one as OLD, on UPDATE);
-- whatever it RETURNs is what gets written. Returning NULL from a BEFORE
-- trigger silently cancels the change for that row. In an AFTER trigger the
-- row is already written, so changing NEW achieves nothing.
-- A `WHEN (...)` clause on CREATE TRIGGER decides whether it fires at all.
--
-- The table (created by the test):
--   posts (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, title text NOT NULL,
--          body text, created_at timestamptz NOT NULL DEFAULT now(),
--          updated_at timestamptz NOT NULL DEFAULT now())
--
-- Task: whenever an UPDATE really changes a post, set its updated_at to now().
-- An UPDATE that changes nothing (e.g. `SET title = title`) leaves
-- updated_at alone.

CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NULL;
END;
$$;

CREATE TRIGGER posts_set_updated_at
AFTER UPDATE ON posts
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

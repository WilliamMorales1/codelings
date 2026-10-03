-- pg4.sql
--
-- INSERT ... ON CONFLICT ... RETURNING
--
-- An "upsert" inserts a row, or updates the existing one if a unique
-- constraint says it is already there -- atomically, in one statement, with
-- no race between a SELECT and an INSERT:
--   INSERT INTO t (k, v) VALUES ($1, $2)
--   ON CONFLICT (k) DO UPDATE SET v = <new value>
-- Inside DO UPDATE, `t.v` is the existing value and `EXCLUDED.v` is the one
-- you tried to insert. RETURNING hands back the row as it ends up.
--
-- The table (created by the test):
--   inventory (sku text PRIMARY KEY, quantity integer NOT NULL CHECK (quantity >= 0),
--              restocked_at timestamptz NOT NULL DEFAULT now())
--
-- Task: record a delivery of $2 units of item $1. A new sku is inserted; for
-- a known sku the quantities add up and restocked_at is set to now().
-- Return sku and quantity.

INSERT INTO inventory (sku, quantity)
VALUES ($1, $2)
ON CONFLICT DO NOTHING
RETURNING sku, quantity;

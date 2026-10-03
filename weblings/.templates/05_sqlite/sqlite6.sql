-- sqlite6.sql
--
-- JSON in SQLite: ->>, json_each and generated columns
--
-- SQLite stores JSON as TEXT and ships functions to pick it apart:
--   payload -> '$.type'     JSON value   ('"click"', quotes included)
--   payload ->> '$.type'    SQL value    ('click')
--   json_each(payload, '$.tags')   a table-valued function: one row per
--                                  array element, with the element in `value`
-- A generated column computes itself from other columns:
--   kind TEXT GENERATED ALWAYS AS (<expression>) VIRTUAL
-- and can be indexed like any column -- handy for a JSON field you filter on.
--
-- Task: finish the schema.
--   - events.kind is generated from payload's "type", as plain text, indexed
--     by events_kind_idx
--   - the view event_tags has one row per (event_id, tag) from payload's
--     "tags" array
-- The test inserts events like {"type": "click", "tags": ["ui", "beta"]}.

CREATE TABLE events (
  id      INTEGER PRIMARY KEY,
  payload TEXT NOT NULL CHECK (json_valid(payload)),
  kind    TEXT GENERATED ALWAYS AS (payload -> '$.type') VIRTUAL
);

-- TODO: index on kind

CREATE VIEW event_tags AS
SELECT events.id AS event_id, payload ->> '$.tags' AS tag
FROM events;

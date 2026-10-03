-- sqlite6.sql -- reference solution.

CREATE TABLE events (
  id      INTEGER PRIMARY KEY,
  payload TEXT NOT NULL CHECK (json_valid(payload)),
  kind    TEXT GENERATED ALWAYS AS (payload ->> '$.type') VIRTUAL
);

CREATE INDEX events_kind_idx ON events (kind);

CREATE VIEW event_tags AS
SELECT events.id AS event_id, t.value AS tag
FROM events, json_each(events.payload, '$.tags') AS t;

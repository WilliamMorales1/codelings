import { beforeEach, expect, test } from 'vitest';
import { readEx, sqlite } from '../helpers.js';

let db;
beforeEach(async () => {
  db = await sqlite();
  db.exec(readEx('05_sqlite', 'sqlite6.sql'));
  const add = db.prepare('INSERT INTO events (payload) VALUES (?)');
  add.run(JSON.stringify({ type: 'click', tags: ['ui', 'beta'] }));
  add.run(JSON.stringify({ type: 'view', tags: [] }));
  add.run(JSON.stringify({ type: 'click', tags: ['ui'] }));
});

const all = (sql) => db.prepare(sql).all().map((r) => ({ ...r }));

test('kind is the plain text of payload.type', () => {
  expect(all('SELECT id, kind FROM events ORDER BY id')).toEqual([
    { id: 1, kind: 'click' },
    { id: 2, kind: 'view' },
    { id: 3, kind: 'click' },
  ]);
  expect(all("SELECT id FROM events WHERE kind = 'click' ORDER BY id")).toEqual([{ id: 1 }, { id: 3 }]);
});

test('kind is indexed', () => {
  const plan = all("EXPLAIN QUERY PLAN SELECT id FROM events WHERE kind = 'click'").map((r) => r.detail).join('\n');
  expect(plan).toContain('events_kind_idx');
});

test('event_tags has one row per tag', () => {
  expect(all('SELECT event_id, tag FROM event_tags ORDER BY event_id, tag')).toEqual([
    { event_id: 1, tag: 'beta' },
    { event_id: 1, tag: 'ui' },
    { event_id: 3, tag: 'ui' },
  ]);
});

test('tags can be counted like any table', () => {
  expect(all('SELECT tag, count(*) AS n FROM event_tags GROUP BY tag ORDER BY n DESC, tag')).toEqual([
    { tag: 'ui', n: 2 },
    { tag: 'beta', n: 1 },
  ]);
});

/* HINT
Use `->>` so kind is 'click', not '"click"'. Add
    CREATE INDEX events_kind_idx ON events (kind);
For the view, join each event with json_each over its tags array:
    SELECT events.id AS event_id, t.value AS tag
    FROM events, json_each(events.payload, '$.tags') AS t;
*/

import { afterAll, beforeAll, expect, test } from 'vitest';
import { freshPg, readEx } from '../helpers.js';

let db;
beforeAll(async () => {
  db = await freshPg();
  await db.exec(`CREATE TABLE posts (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title text NOT NULL,
    body text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
  )`);
  await db.exec(readEx('04_postgres', 'pg8.sql'));
});
afterAll(() => db?.close());

// Start every post with an old timestamp so a fresh now() is easy to spot.
async function oldPost(title) {
  const { rows } = await db.query(
    "INSERT INTO posts (title, created_at, updated_at) VALUES ($1, '2000-01-01', '2000-01-01') RETURNING id",
    [title],
  );
  return rows[0].id;
}
const get = async (id) => (await db.query('SELECT * FROM posts WHERE id = $1', [id])).rows[0];

test('the update itself still happens', async () => {
  const id = await oldPost('draft');
  await db.query("UPDATE posts SET title = 'published' WHERE id = $1", [id]);
  expect((await get(id)).title).toBe('published');
});

test('a real change bumps updated_at', async () => {
  const id = await oldPost('hello');
  await db.query("UPDATE posts SET body = 'world' WHERE id = $1", [id]);
  const post = await get(id);
  expect(post.updated_at.getFullYear()).toBeGreaterThan(2000);
  expect(post.created_at.getFullYear()).toBe(2000);
});

test('a no-op update leaves updated_at alone', async () => {
  const id = await oldPost('same');
  await db.query('UPDATE posts SET title = title WHERE id = $1', [id]);
  expect((await get(id)).updated_at.getFullYear()).toBe(2000);
});

test('it is a row-level BEFORE UPDATE trigger on posts', async () => {
  const { rows } = await db.query(
    "SELECT action_timing, event_manipulation, action_orientation FROM information_schema.triggers WHERE event_object_table = 'posts'",
  );
  expect(rows).toEqual([{ action_timing: 'BEFORE', event_manipulation: 'UPDATE', action_orientation: 'ROW' }]);
});

/* HINT
Make it `BEFORE UPDATE`, and `RETURN NEW;` so the (modified) row is written.
Skip no-op updates with a condition on the trigger:
    FOR EACH ROW
    WHEN (OLD.* IS DISTINCT FROM NEW.*)
    EXECUTE FUNCTION set_updated_at();
*/

import { afterAll, beforeAll, expect, test } from 'vitest';
import { freshPg, pgError, readEx } from '../helpers.js';

let db;
beforeAll(async () => {
  db = await freshPg();
  await db.exec(readEx('04_postgres', 'pg2.sql'));
  await db.exec("INSERT INTO teams (name) VALUES ('core'), ('docs')");
});
afterAll(() => db?.close());

const add = (cols, vals) => db.query(`INSERT INTO members (${cols}) VALUES (${vals}) RETURNING *`);
// SQLSTATE codes: https://www.postgresql.org/docs/current/errcodes-appendix.html
const code = async (fn) => (await pgError(fn))?.code ?? 'no error';

test('a valid member gets an id and the default role', async () => {
  const { rows } = await add('team_id, email, age', "1, 'ada@example.com', 36");
  expect(rows[0]).toMatchObject({ team_id: 1, email: 'ada@example.com', age: 36, role: 'member' });
  expect(typeof rows[0].id).toBe('number');
});

test('id is the primary key and cannot be set by hand', async () => {
  const pk = await db.query(
    "SELECT a.attname FROM pg_index i JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey) WHERE i.indrelid = 'members'::regclass AND i.indisprimary",
  );
  expect(pk.rows).toEqual([{ attname: 'id' }]);
  expect(await code(() => add('id, team_id, email', "99, 1, 'x@example.com'"))).toBe('428C9');
});

test('missing team or email is rejected (not_null_violation)', async () => {
  expect(await code(() => add('email', "'nobody@example.com'"))).toBe('23502');
  expect(await code(() => add('team_id', '1'))).toBe('23502');
});

test('duplicate email is rejected (unique_violation)', async () => {
  await add('team_id, email', "1, 'dup@example.com'");
  expect(await code(() => add('team_id, email', "2, 'dup@example.com'"))).toBe('23505');
});

test('too young or unknown role is rejected (check_violation)', async () => {
  expect(await code(() => add('team_id, email, age', "1, 'kid@example.com', 12"))).toBe('23514');
  expect(await code(() => add('team_id, email, role', "1, 'boss@example.com', 'owner'"))).toBe('23514');
  await add('team_id, email, role', "1, 'admin@example.com', 'admin'");
});

test('unknown team is rejected (foreign_key_violation)', async () => {
  expect(await code(() => add('team_id, email', "999, 'lost@example.com'"))).toBe('23503');
});

test('deleting a team deletes its members', async () => {
  await add('team_id, email', "2, 'docs1@example.com'");
  await db.query("DELETE FROM teams WHERE name = 'docs'");
  const { rows } = await db.query('SELECT count(*)::int AS n FROM members WHERE team_id = 2');
  expect(rows[0].n).toBe(0);
});

/* HINT
    id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    team_id integer NOT NULL REFERENCES teams (id) ON DELETE CASCADE,
    email   text NOT NULL UNIQUE,
    age     integer CHECK (age >= 13),
    role    text NOT NULL DEFAULT 'member' CHECK (role IN ('member', 'admin'))
A CHECK on a NULL age passes -- NULL is "unknown", not false.
*/

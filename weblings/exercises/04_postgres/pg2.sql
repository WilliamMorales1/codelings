-- pg2.sql
--
-- CREATE TABLE with constraints
--
-- Constraints make the database refuse bad data, no matter which program
-- writes it:
--   id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY   -- modern `serial`
--   NOT NULL, UNIQUE, DEFAULT <value>
--   CHECK (<boolean expression>)
--   REFERENCES other_table (id) ON DELETE CASCADE          -- foreign key
--
-- Task: finish `members` so that
--   - id is generated and is the primary key
--   - team_id is required and must name an existing team; deleting a team
--     deletes its members
--   - email is required and unique
--   - age is optional, but when present at least 13
--   - role is 'member' or 'admin', defaulting to 'member'
-- Run it against a real server if you have one: `psql -d scratch -f pg2.sql`

CREATE TABLE teams (
  id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text NOT NULL UNIQUE
);

CREATE TABLE members (
  id      serial,
  team_id integer,
  email   text,
  age     integer,
  role    text
);

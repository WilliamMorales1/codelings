-- pg2.sql -- reference solution.

CREATE TABLE teams (
  id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text NOT NULL UNIQUE
);

CREATE TABLE members (
  id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  team_id integer NOT NULL REFERENCES teams (id) ON DELETE CASCADE,
  email   text NOT NULL UNIQUE,
  age     integer CHECK (age >= 13),
  role    text NOT NULL DEFAULT 'member' CHECK (role IN ('member', 'admin'))
);

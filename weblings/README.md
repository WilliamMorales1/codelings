# weblings

Small exercises to get you used to reading and writing the everyday web stack:
**Node.js**, **React**, **Vite**, **Postgres** and **SQLite** — including
reading test failures and fixing the code that causes them.

Shamelessly modelled on [rustlings](https://github.com/rust-lang/rustlings).
Every exercise is a small file (or a small project directory) whose tests fail.
You fix it and save; once its tests pass the exercise is done and the runner
moves you to the next one.

Everything runs locally and in-process: no Docker, no database server. Postgres
is [PGlite](https://pglite.dev) (real Postgres 18 compiled to WebAssembly),
SQLite is Node's built-in `node:sqlite`. After `npm install` the course works
offline.

## Setup

You need Node.js 22.13 or newer (for `node:sqlite`) and npm:

```sh
sudo pacman -S nodejs npm          # Arch
sudo dnf install nodejs npm        # Fedora
brew install node                  # macOS
```

On Debian/Ubuntu the packaged Node is usually too old; use
[NodeSource](https://github.com/nodesource/distributions) or a version
manager such as [fnm](https://github.com/Schniz/fnm) or [nvm](https://github.com/nvm-sh/nvm)
(these work anywhere). Check with `node --version` (needs 22.13+).

Then install the course's dependencies (vitest, vite, react, jsdom, PGlite —
about 100 MB, all local to this directory):

```sh
git clone https://github.com/WilliamMorales1/codelings
cd codelings/weblings
npm install
node weblings.js doctor           # checks that everything is in place
```

## Usage

```sh
node weblings.js watch            # the main loop: re-checks every time you save
node weblings.js watch react      # ...only one chapter (02, 02_react or react)
node weblings.js                  # check once, stop at the first unsolved exercise
node weblings.js list             # every exercise and its status
node weblings.js run react3       # run one exercise's tests by name
node weblings.js hint react3      # print its hint
node weblings.js solution react3
node weblings.js reset react3     # back to the original, unsolved file(s)
```

The same through npm: `npm run watch`, `npm run verify`, `npm run list`,
`npm run hint -- react3`.

Shorter, with a fish alias:

```fish
alias weblings "node $PWD/weblings.js"
funcsave weblings
weblings watch
```

The runner finds the course by walking up from the current directory, so the
alias works from anywhere inside it.

Open a second terminal with `weblings watch` running, edit the file it points
at, and save. That is the whole workflow. When an exercise fails you see the
vitest output for it, followed by the hint. The spec for every exercise is
`tests/<chapter>/<name>.test.js` — reading it is allowed, and often the fastest
way to see what is expected.

The `File:` line is a terminal hyperlink, so in a terminal that supports OSC 8
(kitty, foot, WezTerm, Ghostty, recent VTE, iTerm2, Windows Terminal) you can
click or ctrl-click it to open the current exercise in your editor. Set
`NO_COLOR=1` to get plain, unadorned output instead.

## The exercises

| Chapter       | What it covers                                                                                                                                                                                                     |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `00_intro`    | the workflow                                                                                                                                                                                                       |
| `01_node`     | ES modules, `fs/promises` + JSON, paths and file URLs (`import.meta.dirname`), `EventEmitter`, streams (`Transform`, `pipeline`), an `http.createServer` JSON API, `util.parseArgs`, `Promise.all` + `AbortSignal` |
| `02_react`    | JSX pitfalls, props and defaults, lists and keys, `useState` updaters, controlled forms, `useEffect` fetching with cleanup, a custom hook (`useDebounce`), context, `useReducer`                                   |
| `03_vite`     | `index.html` as entry, `VITE_` env vars, `base` and build options, `resolve.alias`, dev-server proxy, a plugin with a virtual module                                                                               |
| `04_postgres` | `SELECT`/`WHERE`/`ORDER BY`, constraints, `JOIN` + `GROUP BY`/`HAVING`, `ON CONFLICT` upserts, CTEs + window functions, JSONB, expression and partial indexes, PL/pgSQL triggers, parameterized queries from JS    |
| `05_sqlite`   | prepared statements, `STRICT` tables + foreign keys, transactions, upsert + `RETURNING`, FTS5 full-text search, JSON functions + generated columns, migrations with `user_version`                                 |

40 exercises, named after their chapter (`node1` … `node8`, `react1` …) so
they sort in teaching order. Chapters are independent: if you only care about
SQL, `node weblings.js watch 04` starts you there.

Some notes per chapter:

- **01_node**: plain Node, no frameworks. `node1` is imported by a real
  `node` process, because vitest would forgive things Node does not.
- **02_react**: components are rendered into jsdom with
  [Testing Library](https://testing-library.com/docs/react-testing-library/intro/);
  `fetch` and timers are faked by the tests.
- **03_vite**: each exercise is a tiny project directory. The tests call
  Vite's JavaScript API (`build`, `createServer`) with the exercise as `root`
  and a temporary `outDir`. To poke at one yourself:
  `npx vite exercises/03_vite/vite1` (dev server) or
  `npx vite build exercises/03_vite/vite1 --outDir /tmp/vite1`.
- **04_postgres**: most exercises are `.sql` files run against the shop in
  `tests/fixtures/shop.sql`. PGlite is the real Postgres parser, planner and
  PL/pgSQL, so the same file works on a real server:

  ```sh
  createdb scratch
  psql -d scratch -f tests/fixtures/shop.sql
  psql -d scratch -f exercises/04_postgres/pg3.sql
  ```

  (`pg4.sql` uses `$1`/`$2` placeholders; in psql use `PREPARE` or replace them.)

- **05_sqlite**: `node:sqlite` is synchronous and built in. The `sqlite3`
  CLI (package `sqlite` or `sqlite3`) runs the `.sql` files too.

## Layout

```
exercises/      the files you edit (a file, or a directory for bigger ones)
solutions/      one reference solution per exercise, same shape
.templates/     pristine copies, used by `weblings reset`
tests/          the specs: tests/<chapter>/<name>.test.js drives discovery,
                helpers.js (paths, PGlite/SQLite/Vite helpers), fixtures/
weblings.js     the runner (plain Node, no dependencies), with runner/
scripts/        verify-all.sh: checks that every solution passes and
                every exercise really is broken
```

The runner does not run every test on every save. `verify` and `list` run one
vitest process over all exercises that are not marked pending; `watch` caches
results by file mtime and size and only re-runs exercises whose files changed.

## Adding an exercise

1. Write the spec: `tests/<chapter>/<name>.test.js` (`.jsx` for React). Import
   exercise code through the `@ex` alias (`import { x } from '@ex/01_node/node9.js'`)
   and read non-JS files with `exPath()` / `readEx()` from `tests/helpers.js`
   — never with a hard-coded `exercises/` path, because `scripts/verify-all.sh`
   points the same tests at `solutions/` and at a stripped copy of `exercises/`.
   React specs start with `// @vitest-environment jsdom`.
2. Put a `/* HINT ... */` block at the bottom of the spec; that is where
   `weblings hint` reads from.
3. Add the exercise under `exercises/<chapter>/` as `<name>.<ext>` or a
   directory `<name>/`. Start it with a comment block (title, the idea, the
   task). Its tests must fail as shipped: passing is what marks it done.
4. Add the matching `solutions/<chapter>/<name>…`, copy the exercise to
   `.templates/`, and run `scripts/verify-all.sh`.

Ordering is by chapter, then natural sort of the name, so `node10` comes after
`node9`.

## Other ways to learn

- [Learn Node.js](https://nodejs.org/en/learn) and the [Node.js API docs](https://nodejs.org/api/) — the official guides
- [javascript.info](https://javascript.info/) — the language itself, modules and async included
- [react.dev/learn](https://react.dev/learn) — the React docs, with interactive examples; read [You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
- [Vite guide](https://vite.dev/guide/) and the [plugin API](https://vite.dev/guide/api-plugin)
- [PostgreSQL Exercises](https://pgexercises.com/) — SQL practice in the browser against a real Postgres
- [SQLBolt](https://sqlbolt.com/) — interactive SQL basics
- [The PostgreSQL tutorial](https://www.postgresql.org/docs/current/tutorial.html) and [Use The Index, Luke](https://use-the-index-luke.com/) — indexes, explained properly
- [SQLite documentation](https://sqlite.org/docs.html), especially [FTS5](https://sqlite.org/fts5.html), [JSON](https://sqlite.org/json1.html) and [STRICT tables](https://sqlite.org/stricttables.html)

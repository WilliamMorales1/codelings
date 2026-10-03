// sqlite7.js
//
// Schema migrations with PRAGMA user_version
//
// A schema changes over time; each change is a migration, applied once, in
// order. SQLite keeps a free integer in the database header for exactly this:
//     PRAGMA user_version          -- read it (starts at 0)
//     PRAGMA user_version = 3      -- write it (no placeholders allowed here)
// Record how many migrations have run, and next time run only the rest.
// Run each migration together with its version bump inside one transaction,
// so a failing migration leaves the database at the previous version rather
// than half-changed.
//
// Task: migrate(db, migrations = MIGRATIONS) applies the migrations (an array
// of SQL strings) that have not run yet and returns how many it applied.
// Running it again is a no-op. If one fails, throw, and keep the schema and
// user_version as they were after the last successful migration.

export const MIGRATIONS = [
  `CREATE TABLE users (id INTEGER PRIMARY KEY, email TEXT NOT NULL UNIQUE)`,
  `ALTER TABLE users ADD COLUMN name TEXT`,
  `CREATE TABLE sessions (
     token TEXT PRIMARY KEY,
     user_id INTEGER NOT NULL REFERENCES users (id),
     expires_at TEXT NOT NULL
   )`,
];

export function migrate(db, migrations = MIGRATIONS) {
  for (const sql of migrations) {
    db.exec(sql);
  }
  return migrations.length;
}

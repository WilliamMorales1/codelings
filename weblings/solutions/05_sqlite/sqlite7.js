// sqlite7.js -- reference solution.

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
  const current = db.prepare('PRAGMA user_version').get().user_version;
  let applied = 0;
  for (let v = current; v < migrations.length; v++) {
    db.exec('BEGIN');
    try {
      db.exec(migrations[v]);
      db.exec(`PRAGMA user_version = ${v + 1}`);
      db.exec('COMMIT');
    } catch (err) {
      db.exec('ROLLBACK');
      throw err;
    }
    applied++;
  }
  return applied;
}

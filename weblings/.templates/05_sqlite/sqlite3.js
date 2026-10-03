// sqlite3.js
//
// Transactions: all or nothing
//
// A money transfer is two writes. If the second fails after the first
// succeeded, money has appeared from nowhere -- unless both run inside a
// transaction: BEGIN, do the work, COMMIT; on any error, ROLLBACK and every
// change since BEGIN is undone. With node:sqlite you issue these yourself
// with db.exec(), and use try/catch to decide between COMMIT and ROLLBACK.
// (`db.isTransaction` tells you whether one is open.)
//
// The table (created by the test):
//   accounts (id TEXT PRIMARY KEY, balance INTEGER NOT NULL CHECK (balance >= 0)) STRICT
//
// Task: transfer(db, from, to, amount) moves `amount` between accounts.
// If anything fails -- unknown account, insufficient funds (the CHECK
// constraint throws) -- throw an Error and leave every balance untouched,
// with no transaction left open.

export function transfer(db, from, to, amount) {
  const credit = db.prepare('UPDATE accounts SET balance = balance + ? WHERE id = ?');
  const debit = db.prepare('UPDATE accounts SET balance = balance - ? WHERE id = ?');

  if (credit.run(amount, to).changes !== 1) throw new Error(`no account ${to}`);
  if (debit.run(amount, from).changes !== 1) throw new Error(`no account ${from}`);
}

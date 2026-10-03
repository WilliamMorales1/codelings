// sqlite3.js -- reference solution.

export function transfer(db, from, to, amount) {
  const credit = db.prepare('UPDATE accounts SET balance = balance + ? WHERE id = ?');
  const debit = db.prepare('UPDATE accounts SET balance = balance - ? WHERE id = ?');

  db.exec('BEGIN');
  try {
    if (credit.run(amount, to).changes !== 1) throw new Error(`no account ${to}`);
    if (debit.run(amount, from).changes !== 1) throw new Error(`no account ${from}`);
    db.exec('COMMIT');
  } catch (err) {
    db.exec('ROLLBACK');
    throw err;
  }
}

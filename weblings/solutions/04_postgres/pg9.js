// pg9.js -- reference solution.

export async function findCustomerByEmail(db, email) {
  const { rows } = await db.query('SELECT id, name, email FROM customers WHERE email = $1', [email]);
  return rows[0] ?? null;
}

export async function addCustomer(db, { name, email, country }) {
  const { rows } = await db.query(
    'INSERT INTO customers (name, email, country) VALUES ($1, $2, $3) RETURNING id',
    [name, email, country],
  );
  return rows[0].id;
}

export async function customersIn(db, countries) {
  const { rows } = await db.query('SELECT name FROM customers WHERE country = ANY($1) ORDER BY name', [countries]);
  return rows.map((r) => r.name);
}

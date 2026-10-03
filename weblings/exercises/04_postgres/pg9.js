// pg9.js
//
// Parameterized queries (and why string templates are an injection hole)
//
// Never build SQL by pasting values into the text. A value like
// `' OR '1'='1` or `O'Brien` changes the *meaning* of the query. Instead,
// write placeholders ($1, $2, ...) and pass the values separately; the
// server treats them strictly as data:
//     db.query('SELECT * FROM customers WHERE email = $1', [email])
// This is the same API as node-postgres (`pg`), whose Pool/Client also
// have `query(text, values)` returning `{ rows }`. A list goes in as one
// array parameter: `WHERE country = ANY($1)`.
//
// `db` here is a PGlite instance with the shop tables (tests/fixtures/shop.sql).
//
// Task: rewrite all three functions with placeholders.
//   findCustomerByEmail(db, email)  -> { id, name, email } or null
//   addCustomer(db, { name, email, country }) -> the new id
//   customersIn(db, countries)      -> names of customers in any of the
//                                      given countries, sorted by name

export async function findCustomerByEmail(db, email) {
  const { rows } = await db.query(`SELECT id, name, email FROM customers WHERE email = '${email}'`);
  return rows[0] ?? null;
}

export async function addCustomer(db, { name, email, country }) {
  const { rows } = await db.query(
    `INSERT INTO customers (name, email, country) VALUES ('${name}', '${email}', '${country}') RETURNING id`,
  );
  return rows[0].id;
}

export async function customersIn(db, countries) {
  const { rows } = await db.query(`SELECT name FROM customers WHERE country IN (${countries.join(', ')}) ORDER BY name`);
  return rows.map((r) => r.name);
}

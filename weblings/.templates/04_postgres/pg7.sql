-- pg7.sql
--
-- Expression indexes and partial indexes
--
-- An index is only used when the query matches what was indexed. Two useful
-- variants:
--   - expression index: CREATE INDEX ... ON customers (lower(email))
--     indexes the *result* of an expression, so `WHERE lower(email) = $1`
--     can use it. Made UNIQUE, it enforces case-insensitive uniqueness.
--   - partial index: CREATE INDEX ... ON orders (customer_id) WHERE status = 'pending'
--     only indexes the rows matching the WHERE: small, cheap to maintain,
--     and used by queries with the same condition.
--
-- Task: create
--   customers_email_lower_idx    unique, on lower(email)
--   orders_pending_customer_idx  on orders(customer_id), pending orders only
-- Inspect the result with `SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'orders';`

CREATE UNIQUE INDEX customers_email_lower_idx ON customers (email);

CREATE INDEX orders_pending_customer_idx ON orders (customer_id, status);

-- pg7.sql -- reference solution.

CREATE UNIQUE INDEX customers_email_lower_idx ON customers (lower(email));

CREATE INDEX orders_pending_customer_idx ON orders (customer_id) WHERE status = 'pending';

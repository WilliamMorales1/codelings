-- A small shop, shared by the 04_postgres exercises.

CREATE TABLE customers (
  id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name       text NOT NULL,
  email      text NOT NULL UNIQUE,
  country    text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE products (
  id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name     text NOT NULL,
  category text NOT NULL,
  price    numeric(10, 2) NOT NULL CHECK (price >= 0),
  stock    integer NOT NULL DEFAULT 0,
  attrs    jsonb NOT NULL DEFAULT '{}'
);

CREATE TABLE orders (
  id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id integer NOT NULL REFERENCES customers (id),
  status      text NOT NULL CHECK (status IN ('pending', 'paid', 'shipped', 'cancelled')),
  ordered_at  date NOT NULL
);

CREATE TABLE order_items (
  order_id   integer NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
  product_id integer NOT NULL REFERENCES products (id),
  quantity   integer NOT NULL CHECK (quantity > 0),
  unit_price numeric(10, 2) NOT NULL,
  PRIMARY KEY (order_id, product_id)
);

INSERT INTO customers (name, email, country) VALUES
  ('Ada Lovelace',     'ada@example.com',    'UK'),
  ('Linus Torvalds',   'linus@example.com',  'FI'),
  ('Grace Hopper',     'grace@example.com',  'US'),
  ('Margaret Hamilton','maggie@example.com', 'US'),
  ('Tim Berners-Lee',  'tim@example.com',    'UK'),
  ('Ken Thompson',     'ken@example.com',    'US');

INSERT INTO products (name, category, price, stock, attrs) VALUES
  ('SICP',                 'books',       45.00, 3,  '{"pages": 657, "hardcover": true}'),
  ('The C Programming Language', 'books', 39.99, 10, '{"pages": 272}'),
  ('Learn You a Haskell',  'books',       19.99, 7,  '{"pages": 400}'),
  ('Pragmatic Programmer', 'books',       18.50, 0,  '{"pages": 352}'),
  ('Zine: SQL',            'books',       12.00, 25, '{"pages": 32}'),
  ('Rubber Duck',          'accessories',  4.99, 100,'{"color": "yellow", "weight_g": 40}'),
  ('Mechanical Keyboard',  'hardware',   129.00, 5,  '{"color": "black", "wireless": false, "weight_g": 1200}'),
  ('Travel Keyboard',      'hardware',    79.00, 8,  '{"color": "grey", "wireless": true, "weight_g": 450}'),
  ('Trackball',            'hardware',    59.00, 4,  '{"color": "black", "wireless": true, "weight_g": 180}'),
  ('USB-C Hub',            'hardware',    35.00, 12, '{"color": "silver", "wireless": false, "weight_g": 90}'),
  ('Wireless Mouse',       'hardware',    25.00, 30, '{"color": "white", "wireless": true, "weight_g": 95}'),
  ('Sticker Pack',         'accessories',  3.50, 200,'{}');

INSERT INTO orders (customer_id, status, ordered_at) VALUES
  (1, 'shipped',   '2026-01-05'),
  (1, 'paid',      '2026-02-11'),
  (2, 'shipped',   '2026-01-20'),
  (3, 'pending',   '2026-03-02'),
  (3, 'shipped',   '2026-01-15'),
  (4, 'cancelled', '2026-02-01'),
  (5, 'paid',      '2026-03-10'),
  (2, 'pending',   '2026-03-12');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (1, 1, 1, 45.00), (1, 6, 2, 4.99),
  (2, 7, 1, 129.00),
  (3, 2, 1, 39.99), (3, 12, 4, 3.50),
  (4, 8, 1, 79.00), (4, 11, 2, 25.00),
  (5, 3, 2, 19.99), (5, 9, 1, 59.00), (5, 6, 1, 4.99),
  (6, 7, 1, 129.00),
  (7, 5, 3, 12.00),
  (8, 10, 1, 35.00);

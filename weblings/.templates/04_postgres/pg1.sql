-- pg1.sql
--
-- SELECT, WHERE, ORDER BY, LIMIT
--
-- The basic shape of a query. Two Postgres details trip people up:
--   - strings use single quotes: 'books'. Double quotes mean an *identifier*
--     (a column or table name), so "books" looks for a column called books.
--   - without ORDER BY, rows come back in whatever order is cheapest. If the
--     order matters, say so; ASC is the default, DESC reverses it.
--
-- Tables: see tests/fixtures/shop.sql (customers, products, orders, order_items).
--
-- Task: the two most expensive books that cost less than 45 and are in stock
-- (stock > 0). Columns: name, price. Most expensive first.

SELECT name, price
FROM products
WHERE category = "books" AND price < 45
ORDER BY price
LIMIT 2;

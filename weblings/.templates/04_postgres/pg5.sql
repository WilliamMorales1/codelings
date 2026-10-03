-- pg5.sql
--
-- CTEs and window functions
--
-- A window function computes over a set of rows related to the current one
-- *without* collapsing them the way GROUP BY does:
--   rank() OVER (PARTITION BY category ORDER BY price DESC)
--   sum(price) OVER (PARTITION BY category)
-- Window functions run after WHERE, so you cannot filter on them directly.
-- Compute them in a CTE (`WITH ranked AS (...)`) and filter in the outer
-- query. That also means the window sees *all* rows, not just the ones you
-- keep.
--
-- Task: the two most expensive products in each category. Columns:
--   category, name, price,
--   rank   -- 1 for the most expensive in its category
--   share  -- price as a whole-number percentage of the summed price of ALL
--             products in the category (round to the nearest integer)
-- Order by category, then rank.

SELECT category, name, price,
       rank() OVER (PARTITION BY category ORDER BY price DESC) AS rank
       -- TODO: share
FROM products
WHERE rank() OVER (PARTITION BY category ORDER BY price DESC) <= 2
ORDER BY category, rank;

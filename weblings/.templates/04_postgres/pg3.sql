-- pg3.sql
--
-- JOIN, GROUP BY, HAVING
--
-- JOIN combines rows from related tables; GROUP BY folds rows into one per
-- group, and aggregates (count, sum, avg...) summarise each group. Order of
-- evaluation matters:
--   FROM/JOIN -> WHERE (filters rows) -> GROUP BY -> HAVING (filters groups)
--   -> SELECT -> ORDER BY
-- so a condition on an aggregate belongs in HAVING, never in WHERE. And
-- after joining orders to their items, each order appears once per item:
-- count(DISTINCT o.id) counts orders, count(o.id) counts item rows.
--
-- Task: best customers. For each customer, over their orders that are not
-- cancelled: name, the number of orders (`orders`), and the total spent
-- (`revenue`, sum of quantity * unit_price). Only customers with revenue over
-- 100. Biggest revenue first.

SELECT c.name, count(o.id) AS orders, sum(i.quantity * i.unit_price) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.id
JOIN order_items i ON i.order_id = o.id
WHERE sum(i.quantity * i.unit_price) > 100
ORDER BY revenue DESC;

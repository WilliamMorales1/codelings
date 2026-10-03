-- pg3.sql -- reference solution.

SELECT c.name, count(DISTINCT o.id) AS orders, sum(i.quantity * i.unit_price) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.id
JOIN order_items i ON i.order_id = o.id
WHERE o.status <> 'cancelled'
GROUP BY c.id, c.name
HAVING sum(i.quantity * i.unit_price) > 100
ORDER BY revenue DESC;

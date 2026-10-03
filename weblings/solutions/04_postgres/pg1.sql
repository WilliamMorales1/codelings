-- pg1.sql -- reference solution.

SELECT name, price
FROM products
WHERE category = 'books' AND price < 45 AND stock > 0
ORDER BY price DESC
LIMIT 2;

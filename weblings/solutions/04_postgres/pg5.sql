-- pg5.sql -- reference solution.

WITH ranked AS (
  SELECT category, name, price,
         rank() OVER (PARTITION BY category ORDER BY price DESC) AS rank,
         round(100 * price / sum(price) OVER (PARTITION BY category))::int AS share
  FROM products
)
SELECT category, name, price, rank, share
FROM ranked
WHERE rank <= 2
ORDER BY category, rank;

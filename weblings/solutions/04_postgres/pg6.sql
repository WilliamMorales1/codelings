-- pg6.sql -- reference solution.

SELECT name, attrs ->> 'color' AS color, (attrs ->> 'weight_g')::int AS weight_g
FROM products
WHERE attrs @> '{"wireless": true}'
ORDER BY weight_g;

SELECT category, jsonb_object_agg(name, attrs ->> 'color') AS colors
FROM products
WHERE attrs ? 'color'
GROUP BY category
ORDER BY category;

-- pg6.sql
--
-- JSONB operators and aggregates
--
-- products.attrs is a jsonb column. The operators to know:
--   attrs -> 'color'       jsonb value      ("black", with the JSON quotes)
--   attrs ->> 'color'      text value       (black)
--   attrs ? 'color'        does the key exist?
--   attrs @> '{"wireless": true}'   does attrs contain this JSON? (indexable)
-- ->> always gives text, so cast before comparing or sorting numbers:
-- (attrs ->> 'weight_g')::int. And jsonb_agg / jsonb_object_agg build JSON
-- from rows.
--
-- This file holds two queries.
-- Task 1: wireless products: name, color (text), weight_g (an integer),
--         lightest first.
-- Task 2: per category, a JSON object mapping product name -> color, for the
--         products that have a color at all (categories without any are
--         left out). Columns: category, colors. Order by category.

SELECT name, attrs -> 'color' AS color, attrs ->> 'weight_g' AS weight_g
FROM products
WHERE attrs ->> 'wireless' = true
ORDER BY weight_g;

SELECT category, jsonb_object_agg(name, attrs ->> 'color') AS colors
FROM products
GROUP BY category
ORDER BY category;

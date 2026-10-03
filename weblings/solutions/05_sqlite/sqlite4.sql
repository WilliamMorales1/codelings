-- sqlite4.sql -- reference solution.

INSERT INTO page_views (path, views)
VALUES (:path, 1)
ON CONFLICT (path) DO UPDATE SET views = views + 1
RETURNING views;

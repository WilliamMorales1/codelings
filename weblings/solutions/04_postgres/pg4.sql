-- pg4.sql -- reference solution.

INSERT INTO inventory (sku, quantity)
VALUES ($1, $2)
ON CONFLICT (sku) DO UPDATE
  SET quantity = inventory.quantity + EXCLUDED.quantity,
      restocked_at = now()
RETURNING sku, quantity;

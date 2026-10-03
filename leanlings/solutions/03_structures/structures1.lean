-- structures1.lean
--
-- A `structure` bundles several values into one. Each field gets a name and
-- a type, and Lean generates an accessor for each: `p.x`, `p.y`.
--
-- The `Point` below is missing a field.

structure Point where
  x : Nat
  y : Nat
  deriving Repr, BEq

def origin : Point := { x := 0, y := 0 }

#guard origin.x == 0
#guard origin.y == 0

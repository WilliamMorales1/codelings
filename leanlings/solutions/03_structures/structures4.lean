-- structures4.lean
--
-- `deriving` asks Lean to write boilerplate instances for you: `Repr` to
-- print a value, `BEq` to compare two with `==`, `Inhabited` to name a
-- default value.
--
-- This file compares and prints `Colour` values, but the deriving clause is
-- not pulling its weight.

structure Colour where
  red   : Nat
  green : Nat
  blue  : Nat
  deriving Repr, BEq

def black : Colour := { red := 0, green := 0, blue := 0 }

#eval black
#guard black == { red := 0, green := 0, blue := 0 }

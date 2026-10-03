-- structures2.lean
--
-- There are two ways to build a structure value: the field syntax
-- `{ x := 1, y := 2 }`, and the anonymous constructor `<1, 2>` written with
-- angle brackets, which fills the fields in declaration order.
--
-- Write `mkPoint` using either one.

structure Point where
  x : Nat
  y : Nat
  deriving Repr, BEq

def mkPoint (a b : Nat) : Point := { x := a, y := b }

#guard mkPoint 3 4 == { x := 3, y := 4 }
#guard (mkPoint 1 2).y == 2

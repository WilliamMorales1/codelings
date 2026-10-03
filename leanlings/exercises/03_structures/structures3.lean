-- structures3.lean
--
-- Structures are immutable. To "change" one you build a new one, and the
-- `with` syntax copies every field you do not mention:
--
--     { p with x := 99 }
--
-- Use it to write `moveRight`, which increases `x` and leaves `y` alone.

structure Point where
  x : Nat
  y : Nat
  deriving Repr, BEq

def moveRight (p : Point) (d : Nat) : Point := sorry

#guard moveRight { x := 1, y := 5 } 4 == { x := 5, y := 5 }
#guard (moveRight { x := 0, y := 9 } 0).y == 9

/- HINT
`{ p with x := p.x + d }`.
-/

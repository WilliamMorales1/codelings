-- inductive2.lean
--
-- Constructors may carry data. `match` takes a value apart again, one
-- constructor at a time, and Lean will complain if you forget a case.
--
-- `area` is missing a case.

inductive Shape where
  | circle (radius : Nat)
  | rectangle (width height : Nat)
  | square (side : Nat)

def area : Shape -> Nat
  | .rectangle w h => w * h
  | .square s => s * s

#guard area (.rectangle 3 4) == 12
#guard area (.square 5) == 25
#guard area (.circle 10) == 300

/- HINT
Add a `| .circle r => ...` case. The last guard tells you which crude
approximation of pi this exercise expects.
-/

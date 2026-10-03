-- definitions3.lean
--
-- `let` binds a name inside a definition's body. The body of the `let` is
-- the expression that follows it.
--
-- Finish `areaOfRectangle` so that it computes width * height.

def areaOfRectangle : Nat :=
  let width := 7
  let height := 6
  width * height

#guard areaOfRectangle == 42

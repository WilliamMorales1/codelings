-- inductive1.lean
--
-- An `inductive` type lists every way of building one of its values. With
-- no arguments anywhere, it is just an enumeration.
--
-- `Direction` is missing a constructor that `opposite` already handles.

inductive Direction where
  | north
  | south
  | east
  deriving Repr, BEq

def opposite : Direction -> Direction
  | .north => .south
  | .south => .north
  | .east  => .west
  | .west  => .east

#guard opposite .north == .south
#guard opposite .west == .east

/- HINT
Add `| west` to the type. The leading dot in `.west` is shorthand for
`Direction.west`, which Lean resolves from the expected type.
-/

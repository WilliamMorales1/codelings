-- typeclasses3.lean
--
-- Lean's operators are type classes too: `+` is `HAdd.hAdd`, and the
-- simplest way to get it for your own type is an `Add` instance.
--
-- Teach `+` how to add two vectors componentwise.

structure Vec2 where
  x : Int
  y : Int
  deriving Repr, BEq

instance : Add Vec2 where
  add a b := { x := a.x + b.x, y := a.y + b.y }

#guard Vec2.mk 1 2 + Vec2.mk 10 20 == Vec2.mk 11 22
#guard Vec2.mk 0 0 + Vec2.mk (-1) 5 == Vec2.mk (-1) 5

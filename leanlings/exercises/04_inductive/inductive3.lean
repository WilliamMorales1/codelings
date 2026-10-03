-- inductive3.lean
--
-- `Option a` is Lean's answer to "there might be no value here": either
-- `none`, or `some x`. Because the type says so, you cannot forget to handle
-- the missing case.
--
-- `orElse` should return the number inside, or the fallback when there is
-- none.

def orElse (o : Option Nat) (fallback : Nat) : Nat := sorry

#guard orElse (some 7) 0 == 7
#guard orElse none 42 == 42

/- HINT
`match o with | some n => n | none => fallback`.
-/

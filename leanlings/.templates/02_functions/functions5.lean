-- functions5.lean
--
-- A higher-order function takes another function as an argument. Here `f`
-- is a parameter like any other; its type just happens to have an arrow.
--
-- `applyTwice f x` should feed `x` through `f`, then feed the result through
-- `f` again.

def applyTwice (f : Nat -> Nat) (x : Nat) : Nat := sorry

#guard applyTwice (fun n => n + 3) 0 == 6
#guard applyTwice (fun n => n * n) 3 == 81

/- HINT
`f (f x)`. The parentheses matter: `f f x` would mean "apply f to f".
-/

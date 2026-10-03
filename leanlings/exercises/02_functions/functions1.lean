-- functions1.lean
--
-- A function definition lists its parameters, with types, before the colon:
--
--     def name (x : Nat) (y : Nat) : Nat := ...
--
-- Write the body of `double`.

def double (n : Nat) : Nat := sorry

#guard double 0 == 0
#guard double 21 == 42

/- HINT
`2 * n`, or `n + n`. Note that you apply a function by juxtaposition --
`double 21`, with no parentheses.
-/

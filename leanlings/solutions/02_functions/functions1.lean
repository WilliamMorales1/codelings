-- functions1.lean
--
-- A function definition lists its parameters, with types, before the colon:
--
--     def name (x : Nat) (y : Nat) : Nat := ...
--
-- Write the body of `double`.

def double (n : Nat) : Nat := 2 * n

#guard double 0 == 0
#guard double 21 == 42

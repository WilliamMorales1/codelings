-- inductive4.lean
--
-- `Nat` is itself an inductive type: a natural number is either `Nat.zero`
-- or the successor of another one. That is why you can pattern-match on it
-- with the patterns `0` and `n + 1`, and why recursion on it terminates --
-- the argument gets structurally smaller every time.
--
-- Finish `factorial`.

def factorial : Nat -> Nat
  | 0 => 1
  | n + 1 => (n + 1) * factorial n

#guard factorial 0 == 1
#guard factorial 5 == 120

-- monads5.lean
--
-- `mapM` is `map` for effectful functions: it runs the function on every
-- element and collects the results *in the monad*. In `Option` that means
-- the whole thing is `none` as soon as one element fails.
--
-- Write `allHalves`, which halves every number but refuses odd ones.

def half? (n : Nat) : Option Nat :=
  if n % 2 == 0 then some (n / 2) else none

def allHalves (xs : List Nat) : Option (List Nat) := xs.mapM half?

#guard allHalves [2, 4, 6] == some [1, 2, 3]
#guard allHalves [2, 3] == none

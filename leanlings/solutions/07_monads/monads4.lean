-- monads4.lean
--
-- Inside a `do` block you may declare `let mut` variables and loop over a
-- collection with `for`. `Id.run do` runs such a block in the identity
-- monad, which is how you get imperative-looking code that is still pure.
--
-- Finish the loop body of `sumSquares`.

def sumSquares (xs : List Nat) : Nat := Id.run do
  let mut acc := 0
  for x in xs do
    acc := acc + x * x
  return acc

#guard sumSquares [] == 0
#guard sumSquares [1, 2, 3] == 14

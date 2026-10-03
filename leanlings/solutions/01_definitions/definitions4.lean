-- definitions4.lean
--
-- `#check` asks Lean for the type of an expression, `#eval` asks it to run
-- the expression. Neither changes your program -- they are questions you ask
-- the compiler.
--
-- `luckyNumber` is missing entirely; the `#check` and `#eval` below refer to
-- it. Define it so the whole file compiles.

def luckyNumber : Nat := 7

#check luckyNumber
#eval luckyNumber + 1

#guard luckyNumber == 7

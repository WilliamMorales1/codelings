-- intro2.lean
--
-- Lean separates a declaration's *type* from its *value* with `:=`, not `=`.
-- `=` is the proposition "these two things are equal", which is a very
-- different animal. Make this file compile.

def question : String = "What is 6 times 7?"
def answer : Nat = 42

#guard answer == 42

/- HINT
`def name : Type := value`. Two characters are missing on each line.
-/

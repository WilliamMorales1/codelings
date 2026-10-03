-- intro1.lean
--
-- Welcome to leanlings! Every exercise in this collection is a Lean file that
-- does not type-check yet. Fix it and save: as soon as it compiles cleanly,
-- the exercise is done and leanlings moves you along.
--
-- Task: the `#guard` at the bottom wants a different greeting. Fix the
-- string and save.

def greeting : String := "Hello, world!"

#eval greeting

#guard greeting == "Hello, leanlings!"

/- HINT
`#guard` fails the build when its condition is false. Make `greeting` equal
"Hello, leanlings!".
-/

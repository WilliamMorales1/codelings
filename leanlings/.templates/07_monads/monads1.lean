-- monads1.lean
--
-- `IO a` is the type of a program that, when run, may touch the outside
-- world and produces an `a`. `do` blocks sequence such programs, and `<-`
-- runs one and binds its result.
--
-- `greet` uses `:=` where it should be running an action.

def greet : IO Unit := do
  let name := pure "world"
  IO.println s!"Hello, {name}!"

#eval greet

/- HINT
`let name := pure "world"` binds the *action*, not its result, so `name`
is an `IO String` and cannot be interpolated. Use `<-` to run it.
-/

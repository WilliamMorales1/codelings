-- typeclasses4.lean
--
-- Square brackets in a signature ask for an *instance* argument: Lean fills
-- it in by searching for a matching instance. `[ToString a]` is how you say
-- "any type, as long as it can be printed".
--
-- `describe` is stuck on `Nat`; make it work for every printable type.

def describe (x : Nat) : String :=
  "value: " ++ toString x

#guard describe 42 == "value: 42"
#guard describe true == "value: true"
#guard describe "hi" == "value: hi"

/- HINT
`def describe {a : Type} [ToString a] (x : a) : String := ...`. Without the
`[ToString a]` constraint the body could not call `toString`.
-/

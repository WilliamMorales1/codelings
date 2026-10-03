-- definitions1.lean
--
-- `def` introduces a name. Lean checks that the value you give really does
-- have the type you promised.
--
-- Replace `sorry` with a value that makes the `#guard` below succeed. `sorry`
-- is Lean's "I'll do it later" placeholder: it type-checks, but leanlings
-- treats any file that still uses it as unfinished.

def secondsInAMinute : Nat := 60

#guard secondsInAMinute == 60

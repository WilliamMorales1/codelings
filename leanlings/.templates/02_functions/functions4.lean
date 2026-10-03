-- functions4.lean
--
-- Braces mark an *implicit* argument: Lean works it out from the other
-- arguments instead of making you write it. That is how a single `identity`
-- can work for every type at once.
--
-- Fix the signature so `identity` really is polymorphic.

def identity (a : Nat) : Nat := a

#guard identity 3 == 3
#guard identity "leanlings" == "leanlings"
#guard identity true == true

/- HINT
Take a type as an implicit argument and use it: `{a : Type} (x : a) : a`.
Because it is implicit, the call sites stay unchanged.
-/

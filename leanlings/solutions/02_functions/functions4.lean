-- functions4.lean
--
-- Braces mark an *implicit* argument: Lean works it out from the other
-- arguments instead of making you write it. That is how a single `identity`
-- can work for every type at once.
--
-- Fix the signature so `identity` really is polymorphic.

def identity {a : Type} (x : a) : a := x

#guard identity 3 == 3
#guard identity "leanlings" == "leanlings"
#guard identity true == true

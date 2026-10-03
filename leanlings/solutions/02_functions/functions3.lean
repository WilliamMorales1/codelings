-- functions3.lean
--
-- Every Lean function of "several arguments" really takes them one at a
-- time: `add : Nat -> Nat -> Nat` is a function returning a function. So you
-- may apply it to fewer arguments than it expects and get back a function --
-- that is called partial application.
--
-- `addFive` should be `add` waiting for its second argument.

def add (a : Nat) (b : Nat) : Nat := a + b

def addFive : Nat -> Nat := add 5

#guard addFive 10 == 15
#guard addFive 0 == 5

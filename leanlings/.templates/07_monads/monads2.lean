-- monads2.lean
--
-- `do` is not special to `IO`: it works for any monad, `Option` included.
-- There, `<-` means "if this is `none`, give up and return `none`;
-- otherwise unwrap it". That is how a chain of fallible lookups stays flat.
--
-- Write `sumBoth` in that style.

def table : List (String × Nat) :=
  [("a", 1), ("b", 2)]

def lookup? (key : String) : Option Nat :=
  (table.find? (fun p => p.1 == key)).map Prod.snd

def sumBoth (k1 k2 : String) : Option Nat := sorry

#guard sumBoth "a" "b" == some 3
#guard sumBoth "a" "z" == none

/- HINT
do
      let a <- lookup? k1
      let b <- lookup? k2
      return a + b

No `match` and no explicit `none` case: `<-` short-circuits for you.
-/

-- lists1.lean
--
-- `List a` is built from `[]` and `::` ("cons"). `[1, 2, 3]` is notation
-- for `1 :: 2 :: 3 :: []`, and `++` glues two lists together.
--
-- Fix the definitions so the guards hold.

def digits : List Nat := [1, 2, 3]
def more : List Nat := 0 :: digits
def joined : List Nat := digits :: [4, 5]

#guard more == [0, 1, 2, 3]
#guard joined == [1, 2, 3, 4, 5]

/- HINT
`::` puts one element on the front of a list; to join two *lists* you need
`++`.
-/

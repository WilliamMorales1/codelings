-- lists3.lean
--
-- `List.filter` keeps the elements for which the predicate returns `true`.
-- The predicate returns a `Bool`, so use `==`, `<`, `&&` and friends rather
-- than the propositional connectives.
--
-- `evens` should keep only the even numbers.

def evens (xs : List Nat) : List Nat := xs.filter sorry

#guard evens [1, 2, 3, 4] == [2, 4]
#guard evens [1, 3] == []

/- HINT
A number is even when the remainder of dividing by two is zero:
`fun n => n % 2 == 0`.
-/

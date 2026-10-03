-- lists5.lean
--
-- You can also recurse over a list by hand, matching `[]` against
-- `x :: xs`. This is what `map`, `filter` and `foldl` all do underneath.
--
-- Write `myReverse` without using `List.reverse`.

def myReverse : List Nat -> List Nat
  | [] => []
  | x :: xs => sorry

#guard myReverse [] == []
#guard myReverse [1, 2, 3] == [3, 2, 1]

/- HINT
Reverse the tail, then stick `x` on the *end*: `myReverse xs ++ [x]`.
(Quadratic, but clear; an accumulator version is the usual fix.)
-/

-- lists5.lean
--
-- You can also recurse over a list by hand, matching `[]` against
-- `x :: xs`. This is what `map`, `filter` and `foldl` all do underneath.
--
-- Write `myReverse` without using `List.reverse`.

def myReverse : List Nat -> List Nat
  | [] => []
  | x :: xs => myReverse xs ++ [x]

#guard myReverse [] == []
#guard myReverse [1, 2, 3] == [3, 2, 1]

-- lists4.lean
--
-- `List.foldl f init xs` walks the list left to right, carrying an
-- accumulator: `foldl f a [x, y] = f (f a x) y`. Summing, counting and
-- maximising are all folds.
--
-- Write `total` as a fold.

def total (xs : List Nat) : Nat := xs.foldl (fun acc n => acc + n) 0

#guard total [] == 0
#guard total [1, 2, 3, 4] == 10
